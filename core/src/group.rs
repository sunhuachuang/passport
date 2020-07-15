use postcard::{from_bytes, to_allocvec};
use std::collections::HashMap;
use tdn::async_std::io::Result;
use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, LayerSendMessage, PeerAddr, RpcParam, SendMessage};

use crate::apps::AppSymbol;
use crate::error::new_io_error;
use crate::storage::LocalStorage;

#[derive(Serialize, Deserialize)]
pub struct Event {
    pub app: AppSymbol,
    pub event: Vec<u8>,
}

pub type EventResult = (
    AppSymbol,
    Vec<(String, RpcParam)>,
    Vec<GroupSendMessage>,
    Vec<LayerSendMessage>,
);

impl Event {
    pub fn to_bytes(&self) -> Vec<u8> {
        to_allocvec(self).unwrap_or(vec![])
    }

    fn from_bytes(bytes: &[u8]) -> Result<Event> {
        from_bytes(bytes).map_err(|_| new_io_error("serialize event error"))
    }
}

pub struct GroupBus(Arc<RwLock<LocalStorage>>);

impl GroupBus {
    pub fn new(ls: Arc<RwLock<LocalStorage>>) -> Self {
        Self(ls)
    }

    pub fn handle(&mut self, addr: PeerAddr, bytes: &[u8]) -> Result<EventResult> {
        let Event { app, event } = Event::from_bytes(bytes)?;
        let (rpc, group, layer) = app.handle_event(&event)?;
        Ok((app, rpc, group, layer))
    }

    pub async fn leave(&mut self, addr: PeerAddr) -> Result<()> {
        Ok(())
    }
}
