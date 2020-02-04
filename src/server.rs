use std::collections::HashMap;
use tdn::async_std::{
    io::Result,
    sync::{Arc, RwLock, Sender},
};
use tdn::prelude::*;
use tdn::storage::write_local_file;
use tdn::{new_channel, start_with_config};
use tdn_permission::CAPermissionedGroup;

use crate::app::{App, AppList, AppParam};
use crate::event::Event;
use crate::message::{EncodeMode, Message as EventMessage};
use crate::peer::Peer;
use crate::rpc::{new_rpc_handler, State};

pub struct Global {
    pub apps: AppList,
    pub group: CAPermissionedGroup<Peer>,
    pub storage: u32,
    pub sender: Sender<Message>,
}

impl Global {
    fn new(sender: Sender<Message>, group: CAPermissionedGroup<Peer>) -> Global {
        Global {
            sender,
            group,
            apps: AppList::default(),
            storage: 1,
        }
    }
}

pub async fn start() -> Result<()> {
    let (out_send, out_recv) = new_channel();

    let mut config = Config::load();
    let group = CAPermissionedGroup::<Peer>::new(config.group_id, vec![1], vec![1, 2, 3], vec![3]);
    config.p2p_join_data = group.join_bytes();

    let send = start_with_config(out_send, config).await.unwrap();

    // TODO RWLock
    let global = Arc::new(RwLock::new(Global::new(send.clone(), group)));

    let rpc_handler = new_rpc_handler(State(global.clone()));

    while let Some(message) = out_recv.recv().await {
        match message {
            Message::Group(g_msg) => match g_msg {
                GroupMessage::PeerJoin(peer_addr, addr, data) => {
                    global
                        .write()
                        .await
                        .group
                        .join(peer_addr, addr, data, send.clone())
                        .await;
                }
                GroupMessage::PeerJoinResult(peer_addr, is_ok, result) => {
                    global
                        .write()
                        .await
                        .group
                        .join_result(peer_addr, is_ok, result);
                }
                GroupMessage::PeerLeave(peer_addr) => {
                    global.write().await.group.leave(&peer_addr);
                }
                GroupMessage::Event(peer_addr, bytes) => {
                    let event_result = Event::from_bytes(&bytes);
                    if event_result.is_err() {
                        continue;
                    };
                    handle_event(event_result.unwrap(), global.clone()).await;
                }
            },
            Message::Layer(l_msg) => {
                match l_msg {
                    LayerMessage::Upper(gid, bytes) => {
                        let params = Event::from_upper(&bytes);
                        // TODO send to gid to show
                    }
                    LayerMessage::LowerJoinResult(gid, uid, is_ok) => {
                        if is_ok {
                            let param = global.write().await.apps.fixed_tmp(&gid);
                            if param.is_none() {
                                continue;
                            }
                            let param = param.unwrap();
                            for peer_addr in global.read().await.group.peers() {
                                send.send(Message::Group(GroupMessage::Event(
                                    *peer_addr,
                                    Event::build_app_register(gid, *peer_addr, param.clone())
                                        .to_bytes(),
                                )))
                                .await;
                            }
                        } else {
                            global.write().await.apps.remove_tmp(&gid);
                        }
                    }
                    LayerMessage::Lower(..) => {} // Not support lower
                    LayerMessage::LowerJoin(..) => {} // Not support lower
                    LayerMessage::UpperJoin(..) => {} //TODO
                    LayerMessage::UpperJoinResult(..) => {} //TODO
                    LayerMessage::UpperLeave(..) => {} //TODO
                    LayerMessage::UpperLeaveResult(..) => {} //TODO
                }
            }
            Message::Rpc(uid, params, is_ws) => {
                if is_ws {
                    // TODO websocket
                } else {
                    send.send(Message::Rpc(uid, rpc_handler.handle(params).await, false))
                        .await;
                }
            }
        }
    }

    Ok(())
}

async fn handle_event(event: Event, global: Arc<RwLock<Global>>) -> Result<()> {
    match event.message() {
        EventMessage::SyncFile(_peer_addr, file_name, file_mode, file_content) => {
            let bytes = match file_mode {
                EncodeMode::Binary => file_content,
                EncodeMode::Base64 => {
                    let string = String::from_utf8(file_content).unwrap_or("".to_owned());
                    let v: Vec<&str> = string.split(',').collect();
                    if v.len() < 2 {
                        return Ok(());
                    }

                    base64::decode(v[1]).unwrap_or(vec![])
                }
            };

            write_local_file(&file_name, &bytes).await?;
        }
        _ => {}
    }

    Ok(())
}
