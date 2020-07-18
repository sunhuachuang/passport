use simplelog::{
    CombinedLogger, Config as LogConfig, LevelFilter, TermLogger, TerminalMode, WriteLogger,
};
use std::fs::File;
use std::path::PathBuf;

use tdn::{
    async_std::{
        io::Result,
        sync::{Arc, RwLock},
    },
    prelude::*,
};

//use crate::error::new_io_error;
use crate::group::GroupBus;
use crate::layer::LayerBus;
use crate::primitives::DEFAULT_LOG_FILE;
use crate::rpc::{rpc_response, RpcBus};
use crate::storage::Storage;

pub async fn start(db_path: String) -> Result<()> {
    let db_path = PathBuf::from(db_path);
    init_log(db_path.clone());
    info!("Rust DEBUG db path: {:?}", db_path);

    let mut config = Config::load_with_path(db_path.clone()).await;
    config.db_path = Some(db_path.clone());
    // use self sign to bootstrap peer.
    if config.rpc_ws.is_none() {
        // set default ws addr.
        config.rpc_ws = Some("127.0.0.1:8080".parse().unwrap());
    }
    let (peer_id, send, out_recv) = start_with_config(config).await.unwrap();
    info!("Debug: peer id: {}", peer_id.to_hex());

    let storage = Arc::new(RwLock::new(Storage::init(db_path)?));
    let mut rpc_bus = RpcBus::new(storage.clone(), send.clone(), peer_id);
    let mut layer_bus = LayerBus::new(storage.clone());
    let mut group_bus = GroupBus::new(storage);
    let mut tmp_uid = 0; // TODO tmp use.

    while let Ok(message) = out_recv.recv().await {
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
                    // nothing todo.
                    debug!("peer join result, not handle.");
                }
                GroupReceiveMessage::PeerLeave(addr) => {
                    group_bus.leave(addr).await?;
                }
                GroupReceiveMessage::Event(addr, bytes) => {
                    debug!("handle Event from: {:?}!", addr);
                    let handle_result = group_bus.handle(addr, &bytes);
                    match handle_result {
                        Ok((app, rpcs, groups, layers)) => {
                            for g in groups {
                                send.send(SendMessage::Group(g)).await;
                            }

                            for l in layers {
                                send.send(SendMessage::Layer(l)).await;
                            }

                            for r in rpcs {
                                send.send(SendMessage::Rpc(
                                    tmp_uid,
                                    rpc_response(app.to_str(), r.0, r.1),
                                    true,
                                ))
                                .await
                            }
                        }
                        Err(e) => debug!("{}", e),
                    }
                }
            },
            ReceiveMessage::Rpc(uid, params, is_ws) => {
                debug!("uid: {}, rpc comming.", uid);
                tmp_uid = uid;
                send.send(SendMessage::Rpc(uid, rpc_bus.handle(params).await?, is_ws))
                    .await;
            }
            ReceiveMessage::Layer(msg) => {
                debug!("receive layer message.");
                layer_bus.handle(msg).await?;
            }
        }
    }

    Ok(())
}

pub fn init_log(mut db_path: PathBuf) {
    db_path.push(DEFAULT_LOG_FILE);

    CombinedLogger::init(vec![
        TermLogger::new(
            LevelFilter::Debug,
            LogConfig::default(),
            TerminalMode::Mixed,
        )
        .unwrap(),
        WriteLogger::new(
            LevelFilter::Info,
            LogConfig::default(),
            File::create(db_path).unwrap(),
        ),
    ])
    .unwrap();
}
