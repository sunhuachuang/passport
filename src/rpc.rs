use std::collections::HashMap;
use std::net::SocketAddr;
use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcHandler, RpcParam, SendMessage};

use crate::group::{User, UserId};
use crate::rpc_common::{failure_response, response, success_response};
use crate::rpc_user::{new_user_handler, UserState};
use crate::storage::LocalStorage;

pub struct Global {
    pub storage: LocalStorage,
    pub send: Sender<SendMessage>,
    pub addr: PeerAddr,
    pub users: HashMap<UserId, (u64, UserState)>,
    pub rpcs: HashMap<u64, RpcHandler<UserState>>,
}

impl Global {
    fn notify(&self) {}

    pub fn peer_leave(&self, addr: PeerAddr) {}
}

pub type State = Arc<RwLock<Global>>;

pub fn new_global_handler(
    storage: LocalStorage,
    send: Sender<SendMessage>,
    addr: PeerAddr,
) -> (State, RpcHandler<State>) {
    let global = Arc::new(RwLock::new(Global {
        storage,
        send,
        addr,
        users: HashMap::new(),
        rpcs: HashMap::new(),
    }));
    let rpc_handler = new_rpc_handler(global.clone());
    (global, rpc_handler)
}

fn new_rpc_handler(s: State) -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(s);

    // server ping
    rpc_handler.add_method("echo", |params: Vec<RpcParam>, _state: Arc<State>| {
        Box::pin(async { Ok(response("echo", params)) })
    });

    rpc_handler.add_method("new-user", |params: Vec<RpcParam>, state: Arc<State>| {
        Box::pin(async move {
            let seed = params[0].as_str().unwrap().to_owned();
            let password = params[1].as_str().unwrap().to_owned();
            let name = params[2].as_str().unwrap().to_owned();
            let avator = params[3].as_str().unwrap().to_owned();
            let bio = params[4].as_str().unwrap().to_owned();
            let uid = params[5].as_u64().unwrap();

            println!("DEBUG-Yu: New User: {}, avator: {}", name, avator.len());

            let addr = state.read().await.addr.clone();
            let send = state.read().await.send.clone();

            if let Ok(user) = User::init(name, avator, bio, seed) {
                let user_id = user.id.clone();
                let peer_list_result = state.read().await.storage.add_user(addr, password, user);
                if let Ok(peer_list) = peer_list_result {
                    let (s, handler) = new_user_handler(send, peer_list);
                    state.write().await.users.insert(user_id.clone(), (uid, s));
                    state.write().await.rpcs.insert(uid, handler);

                    return Ok(response(
                        "new-user",
                        vec![RpcParam::String(user_id), RpcParam::String(addr.to_hex())],
                    ));
                }
            }

            Ok(failure_response("new-user", "params invalid."))
        })
    });

    // user online.
    rpc_handler.add_method("hello", |params: Vec<RpcParam>, state: Arc<State>| {
        Box::pin(async move {
            let user_id = params[0].as_str().unwrap().to_owned();
            let password = params[1].as_str().unwrap().to_owned();
            let uid = params[2].as_u64().unwrap();

            println!("DEBUG-Yu: Say Hello: {}", user_id);

            let addr = state.read().await.addr.clone();
            let send = state.read().await.send.clone();

            if state.read().await.users.get(&user_id).is_none() {
                let peer_list_result = state
                    .read()
                    .await
                    .storage
                    .load_user(addr, password, &user_id);

                if let Ok(peer_list) = peer_list_result {
                    let (s, handler) = new_user_handler(send, peer_list);
                    state.write().await.users.insert(user_id.clone(), (uid, s));
                    state.write().await.rpcs.insert(uid, handler);
                }
            }

            Ok(response(
                "hello",
                vec![RpcParam::String(user_id), RpcParam::String(addr.to_hex())],
            ))
        })
    });

    // bootstrap
    rpc_handler.add_method("bootstrap", |params: Vec<RpcParam>, state: Arc<State>| {
        Box::pin(async move {
            let socket = params[0].as_str().unwrap();
            if let Ok(addr) = socket.parse::<SocketAddr>() {
                println!("DEBUG-Yu: start bootstrap to: {:?}", addr);
                state
                    .read()
                    .await
                    .send
                    .send(SendMessage::Group(GroupSendMessage::Connect(addr, None)))
                    .await;
            }

            return Ok(success_response("bootstrap"));
        })
    });

    rpc_handler
}
