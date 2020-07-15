use postcard::{from_bytes, to_allocvec};
use tdn::async_std::io::Result;
use tdn::prelude::{GroupSendMessage, PeerAddr, RpcError, RpcHandler, SendMessage};

use crate::error::new_io_error;
use crate::group::Event as BaseEvent;

use super::super::{did::Did, AppSymbol, EventResult};

/// Yu app's Event.
#[derive(Serialize, Deserialize)]
pub enum Event {
    /// my_id, my_addr, my_name, my_avator, remote_id, remote_addr, remark.
    RequestFriend(Did, PeerAddr, String, String, Did, PeerAddr, String),
    /// my_id, remote_id, remote_addr.
    ResponseFriend(Did, Did, PeerAddr),
    /// my_id, remote_id, remote_addr, message.
    Message(Did, Did, PeerAddr, String),
}

impl Event {
    pub fn to_event(&self) -> BaseEvent {
        BaseEvent {
            app: AppSymbol::Yu,
            event: to_allocvec(self).unwrap_or(vec![]),
        }
    }

    pub fn handle(bytes: &[u8]) -> Result<EventResult> {
        let _event = from_bytes(bytes).map_err(|_| new_io_error("serialize event error"))?;

        debug!("Got p2p event yu");

        Ok((vec![], vec![], vec![]))
    }
}
