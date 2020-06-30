use std::collections::HashMap;
use tdn::async_std::io::Result;
use tdn::async_std::sync::{Arc, RwLock, Sender};
use tdn::prelude::{GroupSendMessage, PeerAddr, SendMessage};

use crate::apps::AppSymbol;
use crate::storage::LocalStorage;

struct Event {
    app: u32,
    event: Vec<u8>,
}

impl Event {
    fn to_bytes(&self) -> Vec<u8> {
        vec![]
    }

    fn from_bytes(_bytes: &[u8]) -> Result<Event> {
        Ok(Event {
            app: 0,
            event: vec![],
        })
    }
}

pub struct GroupBus(Arc<RwLock<LocalStorage>>);

impl GroupBus {
    pub fn new(ls: Arc<RwLock<LocalStorage>>) -> Self {
        Self(ls)
    }

    pub async fn handle(&mut self, addr: PeerAddr, bytes: Vec<u8>) -> Result<()> {
        let event = Event::from_bytes(&bytes)?;
        let app = AppSymbol::from_byte(event.app)?;

        Ok(())
    }

    pub async fn leave(&mut self, addr: PeerAddr) -> Result<()> {
        Ok(())
    }
}
