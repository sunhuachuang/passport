use std::path::PathBuf;
use tdn::async_std::{io::Result, sync::Sender};
use tdn::prelude::*;

use crate::error::new_io_error;
use crate::event::{Event, Message as EventMessage};
use crate::group::JoinType;
use crate::rpc::{new_global_handler, State};
use crate::rpc_common::RpcInfo;
use crate::storage::LocalStorage;

pub async fn start(db_path: String) -> Result<()> {
    println!("Rust DEBUG db path: {}", db_path);
    let db_path = PathBuf::from(db_path);
    let mut config = Config::load_with_path(db_path.clone()).await;
    config.db_path = Some(db_path.clone());

    let storage = LocalStorage::init(db_path)?;

    // use self sign to bootstrap peer.
    config.p2p_join_data = JoinType::default();
    if config.rpc_ws.is_none() {
        // set default ws addr.
        config.rpc_ws = Some("127.0.0.1:8080".parse().unwrap());
    }

    let (peer_id, send, out_recv) = start_with_config(config).await.unwrap();
    println!("Debug: peer id: {}", peer_id.to_hex());

    let (global, rpc_handler) = new_global_handler(storage, send.clone(), peer_id);

    while let Some(message) = out_recv.recv().await {
        match message {
            ReceiveMessage::Group(g_msg) => match g_msg {
                GroupReceiveMessage::PeerJoin(addr, ..) => {
                    send.send(SendMessage::Group(GroupSendMessage::PeerJoinResult(
                        addr,
                        true,
                        false,
                        vec![],
                    )))
                    .await;
                }
                GroupReceiveMessage::PeerJoinResult(..) => {
                    // Nothing to db.
                }
                GroupReceiveMessage::PeerLeave(addr) => {
                    global.write().await.peer_leave(addr);
                }
                GroupReceiveMessage::Event(peer_addr, bytes) => {
                    if let Ok(event) = Event::from_bytes(&bytes) {
                        if let Ok(true) = handle_event(&peer_addr, &event, &send, &global).await {
                            // TODO save event.
                        }
                    }
                }
            },
            ReceiveMessage::Rpc(uid, mut params, is_ws) => {
                println!("uid: {}, rpc comming.", uid);
                if global.read().await.rpcs.contains_key(&uid) {
                    let sender = send.clone();
                    if let Some(user_rpc_handler) = global.read().await.rpcs.get(&uid) {
                        sender
                            .send(SendMessage::Rpc(
                                uid,
                                user_rpc_handler.handle(params).await,
                                is_ws,
                            ))
                            .await;
                    }
                } else {
                    if let RpcParam::Array(mut rawparams) = params["params"].take() {
                        rawparams.push(RpcParam::Number(uid.into()));
                        params["params"] = RpcParam::Array(rawparams);
                    }
                    send.send(SendMessage::Rpc(
                        uid,
                        rpc_handler.handle(params).await,
                        is_ws,
                    ))
                    .await;
                }
            }
            ReceiveMessage::Layer(_l_msg) => {
                // TODO layers
            }
        }
    }

    Ok(())
}

async fn handle_event(
    peer_addr: &PeerAddr,
    event: &Event,
    send: &Sender<SendMessage>,
    global: &State,
) -> Result<bool> {
    println!("DEBUG-Yu: Handle event from: {}", peer_addr.short_show());
    if global.read().await.users.contains_key(&event.from) {
        println!("DEBUG-Yu: Send to myself!!!!!!");
        return Err(new_io_error("it is me!"));
    }

    if !global.read().await.users.contains_key(&event.to) {
        println!("DEBUG-Yu: Sended to user not exsit or outline!!!!!!");
        // TODO if exsit this user, save to cache.
        return Err(new_io_error("it is not send to me!"));
    }

    let uid: u64 = global
        .read()
        .await
        .users
        .get(&event.to)
        .map(|(uid, _)| uid.clone())
        .unwrap_or(0);

    match event.msg {
        EventMessage::ApplyFriend(ref from_peer, ref from_user, ref remark) => {
            if !event.verify(&from_peer) {
                return Err(new_io_error("data verify failure!"));
            }
            println!("DEBUG-Yu: got friend request");

            send.send(SendMessage::Rpc(
                uid,
                RpcInfo::ApplyFriend(from_user.clone(), *peer_addr, remark.clone()).json(),
                true,
            ))
            .await;

            if let Some((_, peers)) = global.write().await.users.get_mut(&event.to) {
                peers
                    .write()
                    .await
                    .peers
                    .friend_apply(event.from.clone(), from_peer.clone());
            }

            return Ok(true);
        }
        EventMessage::ReplyFriendSuccess(ref from_peer, ref from_user) => {
            if !event.verify(&from_peer) {
                return Err(new_io_error("data verify failure!"));
            }
            println!("DEBUG-Yu: got friend response success");
            let mut my_application = false;
            if let Some((_, peers)) = global.write().await.users.get_mut(&event.to) {
                my_application = peers
                    .write()
                    .await
                    .peers
                    .friend_reply(event.from.clone(), Some(from_peer.clone()));
            }

            if my_application {
                send.send(SendMessage::Rpc(
                    uid,
                    RpcInfo::ReplyFriend(Some(from_user.clone()), from_user.id.clone(), *peer_addr)
                        .json(),
                    true,
                ))
                .await;
                return Ok(true);
            } else {
                return Ok(false);
            }
        }
        EventMessage::ReplyFriendFailure => {
            println!("DEBUG-Yu: got friend response failure");
            let mut my_application = false;
            if let Some((_, peers)) = global.write().await.users.get_mut(&event.to) {
                my_application = peers
                    .write()
                    .await
                    .peers
                    .friend_reply(event.from.clone(), None);
            }

            if my_application {
                send.send(SendMessage::Rpc(
                    uid,
                    RpcInfo::ReplyFriend(None, event.from.clone(), *peer_addr).json(),
                    true,
                ))
                .await;
                return Ok(true);
            } else {
                return Ok(false);
            }
        }
        EventMessage::Data(ref from, ref _to, ref data_type, ref data_value, ref data_time) => {
            println!("DEBUG-Yu: got friend message");

            send.send(SendMessage::Rpc(
                uid,
                RpcInfo::Message(
                    from.clone(),
                    data_type.clone(),
                    data_value.clone(),
                    data_time.clone(),
                )
                .json(),
                true,
            ))
            .await;

            return Ok(true);
        }
        _ => {
            println!("DEBUG-Yu: nothing!!!");
        }
    }

    Ok(false)
}
