use tdn::prelude::{PeerAddr, RpcHandler};
use tdn::primitive::json;

use super::generate;

pub struct State(pub PeerAddr);

pub fn new_rpc_handler(addr: PeerAddr) -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(State(addr));

    rpc_handler.add_method("echo", |params, _| Box::pin(async { Ok(params.into()) }));

    rpc_handler.add_method("get", |params, _state| {
        Box::pin(async move {
            debug!("Did get get-user rpc call.");
            let did = params[0].as_str().unwrap().to_string();

            // TODO read storage

            Ok(Default::default())
        })
    });

    rpc_handler.add_method("list", |params, _state| {
        Box::pin(async move {
            debug!("Did get list-users rpc call.");
            let did = params[0].as_str().unwrap().to_string();

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

            let (user, sk) = generate(name, avator, state.0, seed);

            // TODO save storage

            Ok(json!([user.hex_id()]))
        })
    });

    rpc_handler.add_method("update", |params, _state| {
        Box::pin(async move {
            debug!("Did get edit-user rpc call.");
            let name = params[0].as_str().unwrap().to_string();
            debug!("Did edit-user name: {}", name);
            let avator = params[1].as_str().unwrap().to_string();
            debug!("Did edit-user avator length: {}", avator.len());
            let bio = params[2].as_str().unwrap().to_string();

            // TODO update storage.
            // TODO Broadcast my new user info.

            Ok(Default::default())
        })
    });

    rpc_handler
}
