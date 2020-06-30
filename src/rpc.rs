use std::collections::HashMap;
use std::net::SocketAddr;
use tdn::async_std::{
    io::Result,
    sync::{Arc, RwLock, Sender},
};
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcError, RpcHandler, RpcParam, SendMessage};
use tdn::primitive::json;

use crate::apps::{AppRpc, AppSymbol};
use crate::storage::LocalStorage;

pub trait RpcState {}

type Handlers = Arc<RwLock<HashMap<AppSymbol, AppRpc>>>;

/// RPC Handler Bus.
/// jsonrpc call like this:
/// ```
/// {
///    "jsonrpc": "2.0",
///    "id": 0,
///    "app": "system", // apps: did / yu / sync...
///    "method": "echo",
///    "params": []
/// }
/// ```
pub struct RpcBus {
    system: RpcHandler<SystemState>,
    rpcs: Handlers,
}

impl RpcBus {
    pub fn new(ls: Arc<RwLock<LocalStorage>>, send: Sender<SendMessage>, addr: PeerAddr) -> Self {
        let handlers = Arc::new(RwLock::new(HashMap::new()));
        Self {
            system: system_rpc_handler(SystemState((handlers.clone(), send, ls, addr))),
            rpcs: handlers,
        }
    }

    pub async fn handle(&mut self, params: RpcParam) -> Result<RpcParam> {
        if let Some(appname) = params.get("app").map(|s| s.as_str()).flatten() {
            let res_appname = appname.clone().into();
            let mut res = if appname == "system" {
                self.system.handle(params).await
            } else {
                let app_res = AppSymbol::from_str(appname);
                if app_res.is_err() {
                    failure_response("App not exsit!")
                } else {
                    if let Some(handler) = self.rpcs.write().await.get(&app_res.unwrap()) {
                        handler.handle(params).await
                    } else {
                        failure_response("App not started!")
                    }
                }
            };

            res["app"] = res_appname;
            return Ok(res);
        }

        Ok(failure_response("No app params in jsonrpc call!"))
    }
}

struct SystemState(
    (
        Handlers,
        Sender<SendMessage>,
        Arc<RwLock<LocalStorage>>,
        PeerAddr,
    ),
);

fn system_rpc_handler(s: SystemState) -> RpcHandler<SystemState> {
    let mut rpc_handler = RpcHandler::new(s);

    rpc_handler.add_method("echo", |params, _| Box::pin(async { Ok(params.into()) }));

    // bootstrap
    rpc_handler.add_method(
        "bootstrap",
        |params: Vec<RpcParam>, state: Arc<SystemState>| {
            Box::pin(async move {
                let socket = params[0].as_str().unwrap();
                info!("add bootstrap to: {}", socket);
                if let Ok(addr) = socket.parse::<SocketAddr>() {
                    (state.0)
                        .1
                        .send(SendMessage::Group(GroupSendMessage::Connect(addr, None)))
                        .await;

                    Ok(Default::default())
                } else {
                    Err(RpcError::Custom("socket address not valid"))
                }
            })
        },
    );

    rpc_handler.add_method(
        "peer_info",
        |_params: Vec<RpcParam>, _state: Arc<SystemState>| {
            Box::pin(async move { Ok(Default::default()) })
        },
    );

    // start app
    rpc_handler.add_method("start", |params: Vec<RpcParam>, state: Arc<SystemState>| {
        Box::pin(async move {
            if params.len() == 0 {
                return Err(RpcError::Custom("Invalid Params!"));
            }

            if let Some(app) = params[0].as_str() {
                info!("start app: {}", app);
                let app_res = AppSymbol::from_str(app);

                if app_res.is_err() {
                    info!("app not exsit");
                    return Err(RpcError::Custom("app not exsit!"));
                }
                let app = app_res.unwrap();

                if (state.0).0.read().await.contains_key(&app) {
                    return Ok(Default::default());
                }

                let handler = app.start((state.0).3);
                (state.0).0.write().await.insert(app, handler);

                return Ok(Default::default());
            }

            return Err(RpcError::Custom("Invalid Params!"));
        })
    });

    // restart running app
    rpc_handler.add_method(
        "restart",
        |params: Vec<RpcParam>, _state: Arc<SystemState>| {
            Box::pin(async move {
                let app = params[0].as_str().unwrap();
                info!("restart app: {}", app);
                Ok(Default::default())
            })
        },
    );

    // stop running app
    rpc_handler.add_method("stop", |params: Vec<RpcParam>, _state: Arc<SystemState>| {
        Box::pin(async move {
            let app = params[0].as_str().unwrap();
            info!("stop app: {}", app);
            Ok(Default::default())
        })
    });

    rpc_handler
}

fn failure_response(reason: &str) -> RpcParam {
    json!({
        "jsonrpc": "2.0",
        "error": {
            "code": -32600,
            "message": reason,
        }
    })
}
