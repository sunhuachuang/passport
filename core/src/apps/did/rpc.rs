use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{PeerAddr, RpcError, RpcHandler, SendMessage};
use tdn::primitive::json;

use crate::storage::Storage;

use super::{generate, Did, User};

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

    rpc_handler.add_method("get", |params, state| {
        Box::pin(async move {
            debug!("Did get get-user rpc call.");
            let id = params[0].as_str().unwrap().to_string();
            let did = Did::from_hex(id).map_err(|_| RpcError::Custom("Did: did invalid"))?;

            match User::load(&did, &state.db).await {
                Some(user) => Ok(json!([user.id.to_hex(), user.name, user.avatar])),
                None => Err(RpcError::Custom("Did: not found user")),
            }
        })
    });

    rpc_handler.add_method("list", |_params, _state| {
        Box::pin(async move {
            debug!("Did get list-users rpc call.");
            //let id = params[0].as_str().unwrap().to_string();

            // TODO read storage

            Ok(Default::default())
        })
    });

    rpc_handler.add_method("create", |params, state| {
        Box::pin(async move {
            debug!("Did::create rpc call.");
            let name = params[0].as_str().unwrap().to_string();
            debug!("Did::create name: {}", name);

            let avator = params[1].as_str().unwrap().to_string();
            debug!("Did::create avator length: {}", avator.len());

            let seed = params[2].as_str().unwrap().as_bytes();

            let (user, sk) = generate(name, avator, seed);

            user.save(&state.db)
                .await
                .map_err(|_| RpcError::Custom("Did: save user db failure"))?;
            user.save_sk(sk);

            Ok(json!([user.hex_id()]))
        })
    });

    rpc_handler.add_method("update", |params, _state| {
        Box::pin(async move {
            debug!("Did get edit-user rpc call.");
            let id = params[0].as_str().unwrap().to_string();
            debug!("Did edit-user id: {}", id);
            let name = params[1].as_str().unwrap().to_string();
            debug!("Did edit-user name: {}", name);
            let avator = params[2].as_str().unwrap().to_string();
            debug!("Did edit-user avator length: {}", avator.len());

            let _did = Did::from_hex(id).map_err(|_| RpcError::Custom("did invalid"))?;

            // TODO update storage.
            // TODO Broadcast my new user info.

            Ok(Default::default())
        })
    });

    rpc_handler
}
