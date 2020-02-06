use std::future::Future;
use tdn::async_std::sync::{Arc, RwLock};
use tdn::prelude::*;

use crate::app::AppParam;
use crate::event::Event;
use crate::message::EncodeMode;
use crate::server::Global;

pub struct State(pub Arc<RwLock<Global>>);

pub fn new_rpc_handler(s: State) -> RpcHandler<State> {
    let mut rpc_handler = RpcHandler::new(s);
    rpc_handler.add_method("echo", |params: Vec<RpcParam>, _state: Arc<State>| {
        Box::pin(async {
            Ok(RpcParam::Array(params))
            //Err(RpcError::InvalidRequest)
        })
    });

    rpc_handler.add_method("sync-file", |params, state| {
        Box::pin(async move {
            let peer_name = params[0].as_str().unwrap();
            let file_name = params[1].as_str().unwrap();
            let file_bytes = params[2].as_str().unwrap();
            println!("{}", file_bytes);

            let peer_addr = state
                .0
                .read()
                .await
                .group
                .get_peer_addr(&peer_name.to_string())
                .map(|peer| peer.clone());

            if peer_addr.is_none() {
                return Err(RpcError::InvalidRequest);
            }
            let peer_addr = peer_addr.unwrap();
            let event = Event::build_sync_file(
                peer_addr,
                file_name,
                EncodeMode::Base64,
                file_bytes.as_bytes().to_vec(),
            );

            state
                .0
                .read()
                .await
                .sender
                .send(Message::Group(GroupMessage::Event(
                    peer_addr,
                    event.to_bytes(),
                )))
                .await;
            Ok(RpcParam::String("Sync File Sucess".to_owned()))
        })
    });

    rpc_handler.add_method("sync", |params, state| {
        Box::pin(async move { Ok(RpcParam::String("TODO".to_owned())) })
    });

    rpc_handler.add_method("store", |params, state| {
        Box::pin(async move { Ok(RpcParam::String("TODO".to_owned())) })
    });

    rpc_handler.add_method(
        "app-register",
        |params: Vec<RpcParam>, state: Arc<State>| {
            Box::pin(async move {
                if params.len() != 4 {
                    return Err(RpcError::InvalidRequest);
                }

                let gid = params[0]
                    .as_str()
                    .map(|gids| {
                        if gids.len() > 2 && &gids[0..2] == "0x" {
                            GroupId::from_hex(gids[2..].to_owned()).ok()
                        } else {
                            Some(GroupId::from_symbol(gids))
                        }
                    })
                    .flatten();

                if gid.is_none() {
                    return Err(RpcError::InvalidRequest);
                }

                let remote_gid = gid.unwrap();

                let addr = "127.0.0.1:7000".parse().unwrap();
                let join_data = vec![];
                let app_param = AppParam::default();
                let self_gid = state.0.read().await.group.id().clone();

                state
                    .0
                    .read()
                    .await
                    .sender
                    .send(Message::Layer(LayerMessage::LowerJoin(
                        self_gid, remote_gid, 0, addr, join_data,
                    )))
                    .await;

                state.0.write().await.apps.add_tmp(remote_gid, app_param);

                Ok(RpcParam::String("App Register Sucess".to_owned()))
            })
        },
    );

    rpc_handler.add_method("app", |params, state| {
        Box::pin(async move { Ok(RpcParam::String("TODO".to_owned())) })
    });

    rpc_handler.add_method("app-delete", |params: Vec<RpcParam>, _state: Arc<State>| {
        Box::pin(async { Ok(RpcParam::String("App Delete Sucess".to_owned())) })
    });

    rpc_handler
}
