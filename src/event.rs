use serde_derive::{Deserialize, Serialize};
use tdn::prelude::{GroupId, PeerAddr};

use crate::app::AppParam;
use crate::message::{EncodeMode, Message};

#[derive(Default, Serialize, Deserialize, Debug)]
pub struct Event {
    message: Message,
}

impl Event {
    fn build(message: Message) -> Event {
        Event { message }
    }

    pub fn build_sync(peer_addr: PeerAddr, value: impl ToString) -> Event {
        Event::build(Message::Sync(peer_addr, value.to_string()))
    }

    pub fn build_sync_file(
        peer_addr: PeerAddr,
        file_name: impl ToString,
        file_mode: EncodeMode,
        file_bytes: Vec<u8>,
    ) -> Event {
        Event::build(Message::SyncFile(
            peer_addr,
            file_name.to_string(),
            file_mode,
            file_bytes,
        ))
    }

    pub fn build_store(value: Vec<u8>) -> Event {
        Event::build(Message::Store(value))
    }

    pub fn build_app_register(gid: GroupId, peer_addr: PeerAddr, app_param: AppParam) -> Event {
        Event::build(Message::AppRegister(gid, peer_addr, app_param))
    }

    pub fn build_app_delete(gid: GroupId) -> Event {
        Event::build(Message::AppDelete(gid))
    }

    pub fn build_app(gid: GroupId, param: AppParam) -> Event {
        Event::build(Message::App(gid, param))
    }

    pub fn message(self) -> Message {
        self.message
    }

    pub fn is_app(&self) -> bool {
        match self.message {
            Message::App { .. } | Message::AppRegister { .. } | Message::AppDelete { .. } => true,
            _ => false,
        }
    }

    pub fn from_bytes(bytes: &Vec<u8>) -> Result<Self, ()> {
        bincode::deserialize(bytes).map_err(|_e| ())
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        bincode::serialize(self).unwrap_or(vec![])
    }

    pub fn from_upper(bytes: &Vec<u8>) -> Vec<AppParam> {
        bincode::deserialize(bytes).unwrap_or(vec![])
    }

    pub fn to_upper(&self) -> Vec<u8> {
        match &self.message {
            Message::App(_gid, params) => bincode::serialize(&vec![&params]).unwrap_or(vec![]),
            _ => vec![],
        }
    }

    /// no lower layer
    pub fn from_lower(_bytes: &Vec<u8>) -> Result<Self, ()> {
        Err(())
    }

    /// no lower layer
    pub fn to_lower(&self) -> Vec<u8> {
        vec![]
    }
}
