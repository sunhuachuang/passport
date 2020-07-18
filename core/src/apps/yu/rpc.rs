use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcError, RpcHandler, SendMessage};

use crate::storage::Storage;

use super::super::did::{Did, User};
use super::group::Event;

pub struct State {
    addr: PeerAddr,
    sender: Sender<SendMessage>,
    db: Arc<RwLock<Storage>>,
}

pub fn new_rpc_handler(
    addr: PeerAddr,
    sender: Sender<SendMessage>,
    db: Arc<RwLock<Storage>>,
) -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(State { addr, sender, db });

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

            let (my_name, my_avatar) = match User::load(&my_did, &state.db).await {
                Some(user) => (user.name, user.avatar),
                None => ("".to_owned(), "".to_owned()),
            };

            // send to p2p
            state
                .sender
                .send(SendMessage::Group(GroupSendMessage::Event(
                    remote_addr,
                    Event::RequestFriend(
                        my_did, state.addr, my_name, my_avatar, remote_did, remark,
                    )
                    .to_event()
                    .to_bytes(),
                )))
                .await;

            Ok(Default::default())
        })
    });

    rpc_handler.add_method("response-friend", |params, state| {
        Box::pin(async move {
            debug!("Yu::response-friend.");
            let my_id = params[0].as_str().unwrap().to_string();
            debug!("Yu::response-friend my id: {}", my_id);

            let remote_id = params[1].as_str().unwrap().to_string();
            debug!("Yu::response-friend remote id: {}", remote_id);

            let remote_addr = params[2].as_str().unwrap().to_string();
            debug!("Yu::response-friend remote addr: {}", remote_addr);
            let is_ok = params[3].as_str().unwrap().to_string();

            let my_did = Did::from_hex(my_id).map_err(|_| RpcError::Custom("did invalid"))?;
            let remote_did =
                Did::from_hex(remote_id).map_err(|_| RpcError::Custom("did invalid"))?;
            let remote_addr = PeerAddr::from_hex(remote_addr)
                .map_err(|_| RpcError::Custom("peer addr invalid"))?;

            let event = if is_ok != String::from("1") {
                Event::RejectFriend(my_did, remote_did)
            } else {
                let (my_name, my_avatar) = match User::load(&my_did, &state.db).await {
                    Some(user) => (user.name, user.avatar),
                    None => ("".to_owned(), "".to_owned()),
                };

                Event::AgreeFriend(my_did, state.addr, my_name, my_avatar, remote_did)
            };

            // send to p2p
            state
                .sender
                .send(SendMessage::Group(GroupSendMessage::Event(
                    remote_addr,
                    event.to_event().to_bytes(),
                )))
                .await;

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
