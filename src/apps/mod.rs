use serde_derive::{Deserialize, Serialize};
use std::collections::HashMap;
use tdn::async_std::io::Result;
use tdn::prelude::{GroupId, PeerAddr, RpcHandler, RpcParam};

use crate::error::new_io_error;

mod did;
mod ds;
mod sync;
mod yu;

#[derive(Hash, Eq, PartialEq)]
pub enum AppSymbol {
    Did,
    Yu,
    Sync,
    Ds,
}

impl AppSymbol {
    pub fn from_str(s: &str) -> Result<AppSymbol> {
        match s {
            "did" => Ok(AppSymbol::Did),
            "yu" => Ok(AppSymbol::Yu),
            "sync" => Ok(AppSymbol::Sync),
            "Ds" => Ok(AppSymbol::Ds),
            _ => Err(new_io_error("App not found!")),
        }
    }

    pub fn from_byte(b: u32) -> Result<AppSymbol> {
        match b {
            1u32 => Ok(AppSymbol::Did),
            2u32 => Ok(AppSymbol::Yu),
            3u32 => Ok(AppSymbol::Sync),
            4u32 => Ok(AppSymbol::Ds),
            _ => Err(new_io_error("App not found!")),
        }
    }

    pub fn start(&self, addr: PeerAddr) -> AppRpc {
        match self {
            AppSymbol::Did => AppRpc::Did(did::rpc::new_rpc_handler(addr)),
            AppSymbol::Yu => AppRpc::Yu(yu::rpc::new_rpc_handler()),
            AppSymbol::Sync => AppRpc::Sync(sync::rpc::new_rpc_handler()),
            AppSymbol::Ds => AppRpc::Ds(ds::rpc::new_rpc_handler()),
        }
    }
}

pub enum AppRpc {
    Did(RpcHandler<did::rpc::State>),
    Yu(RpcHandler<yu::rpc::State>),
    Sync(RpcHandler<sync::rpc::State>),
    Ds(RpcHandler<ds::rpc::State>),
}

impl AppRpc {
    pub async fn handle(&self, params: RpcParam) -> RpcParam {
        match self {
            AppRpc::Did(x) => x.handle(params).await,
            AppRpc::Yu(x) => x.handle(params).await,
            AppRpc::Sync(x) => x.handle(params).await,
            AppRpc::Ds(x) => x.handle(params).await,
        }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Param {
    U128(u128),
    U64(u64),
    U32(u32),
    U16(u16),
    U8(u8),
    I128(i128),
    I64(i64),
    I32(i32),
    I16(i16),
    I8(i8),
    F32(f32),
    F64(f64),
    String(String),
    Text(String),
    Checkbox(bool),
    Radio(u32, Vec<String>),
    File(Vec<u8>),
}

// method: [
//   (param_name: param_type),
//   (param_name: param_type)
// ]
#[derive(Serialize, Deserialize)]
pub struct App {
    id: GroupId,
    params: HashMap<String, Vec<(String, Param)>>,
}

#[derive(Serialize, Deserialize, Default, Clone, Debug)]
pub struct AppParam {
    params: HashMap<String, Vec<(String, Param)>>,
    peer_id: Vec<u8>,
    pk: Vec<u8>,
    sign: Vec<u8>,
}

#[derive(Default)]
pub struct AppList {
    _apps: HashMap<GroupId, Vec<PeerAddr>>,
    _tmps: HashMap<GroupId, AppParam>,
    _local_apps: HashMap<GroupId, AppParam>,
}

impl AppList {
    pub fn _add_tmp(&mut self, gid: GroupId, param: AppParam) {
        info!("hehehe: {:?}", gid);
        self._tmps.insert(gid, param);
    }

    pub fn _fixed_tmp(&mut self, gid: &GroupId) -> Option<AppParam> {
        info!("hehehe: {:?}", gid);
        let param = self._tmps.remove(gid);
        if param.is_some() {
            let param = param.unwrap();
            self._local_apps.insert(*gid, param.clone());
            Some(param)
        } else {
            None
        }
    }

    pub fn _remove_tmp(&mut self, gid: &GroupId) {
        self._tmps.remove(gid);
    }
}
