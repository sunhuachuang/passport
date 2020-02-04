use serde_derive::{Deserialize, Serialize};
use std::collections::HashMap;
use tdn::prelude::{GroupId, PeerAddr};

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
    apps: HashMap<GroupId, Vec<PeerAddr>>,
    tmps: HashMap<GroupId, AppParam>,
    local_apps: HashMap<GroupId, AppParam>,
}

impl AppList {
    pub fn add_tmp(&mut self, gid: GroupId, param: AppParam) {
        println!("hehehe: {:?}", gid);
        self.tmps.insert(gid, param);
    }

    pub fn fixed_tmp(&mut self, gid: &GroupId) -> Option<AppParam> {
        println!("hehehe: {:?}", gid);
        let param = self.tmps.remove(gid);
        if param.is_some() {
            let param = param.unwrap();
            self.local_apps.insert(*gid, param.clone());
            Some(param)
        } else {
            None
        }
    }

    pub fn remove_tmp(&mut self, gid: &GroupId) {
        self.tmps.remove(gid);
    }
}
