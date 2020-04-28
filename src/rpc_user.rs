use std::net::SocketAddr;
use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcHandler, RpcParam, SendMessage};

use crate::group::{Friend, PeerList, User, UserId};
use crate::rpc_common::{failure_response, success_response};

pub struct UserGlobal {
    pub send: Sender<SendMessage>,
    pub peers: PeerList,
}

pub type UserState = Arc<RwLock<UserGlobal>>;

pub fn new_user_handler(
    send: Sender<SendMessage>,
    peers: PeerList,
) -> (UserState, RpcHandler<UserState>) {
    let state = Arc::new(RwLock::new(UserGlobal { send, peers }));
    (state.clone(), new_user_rpc_handler(state))
}

fn new_user_rpc_handler(s: UserState) -> RpcHandler<UserState> {
    let mut rpc_handler = RpcHandler::new(s);

    // bootstrap
    rpc_handler.add_method(
        "bootstrap",
        |params: Vec<RpcParam>, state: Arc<UserState>| {
            Box::pin(async move {
                let socket = params[0].as_str().unwrap();
                println!("DEBUG-Yu: start bootstrap to: {}", socket);
                if let Ok(addr) = socket.parse::<SocketAddr>() {
                    state
                        .read()
                        .await
                        .send
                        .send(SendMessage::Group(GroupSendMessage::Connect(addr, None)))
                        .await;
                    Ok(success_response("bootstrap"))
                } else {
                    Ok(failure_response("bootstrap", "socket address not valid"))
                }
            })
        },
    );

    rpc_handler.add_method("edit-user", |params, _state| {
        Box::pin(async move {
            println!("DEBUG Rust Got edit-user");
            let my_user_name = params[0].as_str().unwrap();
            println!("DEBUG Rust edit-user: {}", my_user_name);
            let my_user_avator = params[1].as_str().unwrap();
            println!("DEBUG Rust edit-user avator: {}", my_user_avator.len());
            let my_user_bio = params[2].as_str().unwrap();
            println!("DEBUG Rust Got edit-user: {}", my_user_bio);

            // TODO Broadcast my new user info.

            println!("DEBUG Rust edit user ok!");

            Ok(failure_response("edit-user", "not implement."))
        })
    });

    rpc_handler.add_method("online", |_, _| {
        Box::pin(async { Ok(failure_response("online", "not implement.")) })
    });
    rpc_handler.add_method("offline", |_, _| {
        Box::pin(async { Ok(failure_response("offline", "not implement.")) })
    });

    rpc_handler.add_method("message", |params, state| {
        Box::pin(async move {
            let to_user_id = params[0].as_str().unwrap().to_owned();
            let data_type = params[1].as_str().unwrap();
            let data_value = params[2].as_str().unwrap().to_owned();
            let data_time = params[3].as_str().unwrap().to_owned();
            println!("DEBUG-Yu: message to {}, {}", to_user_id, data_value);

            let result = state.write().await.peers.message_friend(
                to_user_id,
                data_type.parse::<u32>().unwrap_or(1),
                data_value,
                data_time,
            );

            if let Some((addr, event)) = result {
                println!("DEBUG-Yu: message event to {}", addr.to_hex());
                state
                    .read()
                    .await
                    .send
                    .send(SendMessage::Group(GroupSendMessage::Event(
                        addr,
                        event.as_bytes(),
                    )))
                    .await;
                return Ok(success_response("message"));
            }

            Ok(failure_response("message", "user not friend or offline."))
        })
    });

    rpc_handler.add_method("apply-friend", |params, state| {
        Box::pin(async move {
            let to_user_id = params[0].as_str().unwrap().to_owned();
            let to_peer_addr = params[1].as_str().unwrap().to_owned();
            let remark = params[2].as_str().unwrap().to_owned();

            println!("DEBUG-Yu: Apply friend: to user: {}", to_user_id);

            let event = state.write().await.peers.apply_friend(to_user_id, remark);
            state
                .read()
                .await
                .send
                .send(SendMessage::Group(GroupSendMessage::Event(
                    PeerAddr::from_hex(to_peer_addr).unwrap_or(Default::default()),
                    event.as_bytes(),
                )))
                .await;

            return Ok(success_response("apply-friend"));
        })
    });

    rpc_handler.add_method("reply-friend", |params, state| {
        Box::pin(async move {
            let to_user_id = params[0].as_str().unwrap().to_owned();
            let to_peer_addr = params[1].as_str().unwrap().to_owned();
            let is_ok = params[2].as_str().unwrap() != "0";

            println!("DEBUG-Yu: Reply friend: to user: {}", to_user_id);

            let event = state.write().await.peers.reply_friend(to_user_id, is_ok);

            state
                .read()
                .await
                .send
                .send(SendMessage::Group(GroupSendMessage::Event(
                    PeerAddr::from_hex(to_peer_addr).unwrap_or(Default::default()),
                    event.as_bytes(),
                )))
                .await;

            return Ok(success_response("reply-friend"));
        })
    });

    rpc_handler.add_method("close-friend", |_, _| {
        Box::pin(async { Ok(failure_response("close-friend", "not implement.")) })
    });
    rpc_handler.add_method("black-friend", |_, _| {
        Box::pin(async { Ok(failure_response("black-friend", "not implement.")) })
    });
    // group handler
    rpc_handler.add_method("new-group", |_, _| {
        Box::pin(async { Ok(failure_response("group", "not implement.")) })
    });
    rpc_handler.add_method("invite-group", |_, _| {
        Box::pin(async { Ok(failure_response("group", "not implement.")) })
    });
    rpc_handler.add_method("join-group", |_, _| {
        Box::pin(async { Ok(failure_response("group", "not implement.")) })
    });
    rpc_handler.add_method("offline-group", |_, _| {
        Box::pin(async { Ok(failure_response("group", "not implement.")) })
    });
    rpc_handler.add_method("leave-group", |_, _| {
        Box::pin(async { Ok(failure_response("group", "not implement.")) })
    });

    rpc_handler
}
