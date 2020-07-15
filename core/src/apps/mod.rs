use std::collections::HashMap;
use tdn::async_std::io::Result;
use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{
    GroupId, GroupSendMessage, LayerSendMessage, PeerAddr, RpcHandler, RpcParam, SendMessage,
};

use crate::storage::LocalStorage;

use crate::error::new_io_error;

mod did;
mod docs;
mod ds;
mod yu;

#[derive(Hash, Eq, PartialEq, Serialize, Deserialize)]
pub enum AppSymbol {
    Did,
    Yu,
    Docs,
    Ds,
}

pub(super) type EventResult = (
    Vec<(String, RpcParam)>,
    Vec<GroupSendMessage>,
    Vec<LayerSendMessage>,
);

impl AppSymbol {
    pub fn from_str(s: &str) -> Result<AppSymbol> {
        match s {
            "did" => Ok(AppSymbol::Did),
            "ds" => Ok(AppSymbol::Ds),
            "yu" => Ok(AppSymbol::Yu),
            "docs" => Ok(AppSymbol::Docs),
            _ => Err(new_io_error("App not found!")),
        }
    }

    pub fn to_str<'a>(&self) -> &'a str {
        match self {
            AppSymbol::Did => "did",
            AppSymbol::Ds => "ds",
            AppSymbol::Yu => "yu",
            AppSymbol::Docs => "docs",
        }
    }

    pub fn start(
        &self,
        addr: PeerAddr,
        send: Sender<SendMessage>,
        db: Arc<RwLock<LocalStorage>>,
    ) -> AppRpc {
        match self {
            AppSymbol::Did => AppRpc::Did(did::rpc::new_rpc_handler(addr)),
            AppSymbol::Ds => AppRpc::Ds(ds::rpc::new_rpc_handler()),
            AppSymbol::Yu => AppRpc::Yu(yu::rpc::new_rpc_handler(addr, send, db)),
            AppSymbol::Docs => AppRpc::Docs(docs::rpc::new_rpc_handler()),
        }
    }

    pub fn handle_event(&self, bytes: &[u8]) -> Result<EventResult> {
        match self {
            AppSymbol::Did => did::group::Event::handle(bytes),
            AppSymbol::Ds => ds::group::Event::handle(bytes),
            AppSymbol::Yu => yu::group::Event::handle(bytes),
            AppSymbol::Docs => docs::group::Event::handle(bytes),
        }
    }
}

pub enum AppRpc {
    Did(RpcHandler<did::rpc::State>),
    Ds(RpcHandler<ds::rpc::State>),
    Yu(RpcHandler<yu::rpc::State>),
    Docs(RpcHandler<docs::rpc::State>),
}

impl AppRpc {
    pub async fn handle(&self, params: RpcParam) -> RpcParam {
        match self {
            AppRpc::Did(x) => x.handle(params).await,
            AppRpc::Ds(x) => x.handle(params).await,
            AppRpc::Yu(x) => x.handle(params).await,
            AppRpc::Docs(x) => x.handle(params).await,
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
