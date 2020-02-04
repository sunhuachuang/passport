use serde_derive::{Deserialize, Serialize};
use tdn::prelude::*;

use crate::app::{App, AppParam};

#[derive(Serialize, Deserialize, Debug)]
pub enum EncodeMode {
    Binary,
    Base64,
}

#[derive(Serialize, Deserialize, Debug)]
pub enum Message {
    Sync(PeerAddr, String),
    SyncFile(PeerAddr, String, EncodeMode, Vec<u8>),
    Store(Vec<u8>),
    AppRegister(GroupId, PeerAddr, AppParam),
    AppDelete(GroupId),
    App(GroupId, AppParam),
    None,
}

impl Default for Message {
    fn default() -> Message {
        Message::None
    }
}
