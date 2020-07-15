use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcError, RpcHandler, SendMessage};

use crate::storage::LocalStorage;

use super::super::did::Did;
use super::group::Event;

pub struct State {
    addr: PeerAddr,
    send: Sender<SendMessage>,
    db: Arc<RwLock<LocalStorage>>,
}

pub fn new_rpc_handler(
    addr: PeerAddr,
    send: Sender<SendMessage>,
    db: Arc<RwLock<LocalStorage>>,
) -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(State { addr, send, db });

    rpc_handler.add_method("echo", |params, _| Box::pin(async { Ok(params.into()) }));

    rpc_handler.add_method("request-friend", |params, state| {
        Box::pin(async move {
            debug!("Yu::request-friend.");
            let my_id = params[0].as_str().unwrap().to_string();
            debug!("Yu::request-friend my id: {}", my_id);

            let remote_id = params[1].as_str().unwrap().to_string();
            debug!("Yu::request-friend remote id: {}", remote_id);

            let remote_addr = params[2].as_str().unwrap().to_string();
            debug!("Yu::request-friend remote addr: {}", remote_addr);

            let remark = params[3].as_str().unwrap().to_string();
            debug!("Yu::request-friend remark: {}", remark);

            let my_did = Did::from_hex(my_id).map_err(|_| RpcError::Custom("did invalid"))?;
            let remote_did =
                Did::from_hex(remote_id).map_err(|_| RpcError::Custom("did invalid"))?;
            let remote_addr = PeerAddr::from_hex(remote_addr)
                .map_err(|_| RpcError::Custom("peer addr invalid"))?;

            // TODO load from db.
            let my_name = "".to_owned();
            let my_avator = "".to_owned();

            // send to p2p
            state
                .send
                .send(SendMessage::Group(GroupSendMessage::Event(
                    remote_addr,
                    Event::RequestFriend(
                        my_did,
                        state.addr,
                        my_name,
                        my_avator,
                        remote_did,
                        remote_addr,
                        remark,
                    )
                    .to_event()
                    .to_bytes(),
                )))
                .await;

            Ok(Default::default())
        })
    });

    rpc_handler.add_method("response-friend", |params, _state| {
        Box::pin(async move {
            debug!("Yu::response-friend.");
            let my_id = params[0].as_str().unwrap().to_string();
            debug!("Yu::response-friend my id: {}", my_id);

            let remote_id = params[1].as_str().unwrap().to_string();
            debug!("Yu::response-friend remote id: {}", remote_id);

            let remote_addr = params[2].as_str().unwrap().to_string();
            debug!("Yu::response-friend remote addr: {}", remote_addr);

            // send to p2p

            Ok(Default::default())
        })
    });

    rpc_handler.add_method("message", |params, _state| {
        Box::pin(async move {
            debug!("Yu::message.");
            let my_id = params[0].as_str().unwrap().to_string();
            debug!("Yu::message my id: {}", my_id);

            let remote_id = params[1].as_str().unwrap().to_string();
            debug!("Yu::message remote id: {}", remote_id);

            let remote_addr = params[2].as_str().unwrap().to_string();
            debug!("Yu::message remote addr: {}", remote_addr);

            let message = params[3].as_str().unwrap().to_string();
            debug!("Yu::message message: {}", message);

            // send to p2p

            Ok(Default::default())
        })
    });

    rpc_handler
}
