use tdn::prelude::RpcHandler;

pub struct State;

pub fn new_rpc_handler() -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(State);

    rpc_handler.add_method("echo", |params, _| Box::pin(async { Ok(params.into()) }));

    rpc_handler
}
