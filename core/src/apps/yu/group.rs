use postcard::{from_bytes, to_allocvec};
use tdn::async_std::io::Result;
use tdn::prelude::{GroupSendMessage, LayerSendMessage, PeerAddr, RpcParam};
use tdn::primitive::json;

use crate::error::new_io_error;
use crate::group::Event as BaseEvent;

use super::super::{did::Did, AppSymbol, EventResult};

/// Yu app's Event.
#[derive(Serialize, Deserialize)]
pub enum Event {
    /// my_id, my_addr, my_name, my_avatar, remote_id, remark.
    RequestFriend(Did, PeerAddr, String, String, Did, String),
    /// my_id, remote_id.
    RejectFriend(Did, Did),
    /// my_id, my_addr, my_name, my_avatar, remote_id.
    AgreeFriend(Did, PeerAddr, String, String, Did),
    /// my_id, remote_id, message.
    Message(Did, Did, String),
}

impl Event {
    pub fn to_event(&self) -> BaseEvent {
        BaseEvent {
            app: AppSymbol::Yu,
            event: to_allocvec(self).unwrap_or(vec![]),
        }
    }

    pub fn handle(bytes: &[u8]) -> Result<EventResult> {
        let event = from_bytes(bytes).map_err(|_| new_io_error("serialize event error"))?;

        let mut rpcs: Vec<(&str, RpcParam)> = vec![];
        let groups: Vec<GroupSendMessage> = vec![];
        let layers: Vec<LayerSendMessage> = vec![];

        match event {
            Event::RequestFriend(
                remote_id,
                remote_addr,
                remote_name,
                remote_avatar,
                my_id,
                remark,
            ) => rpcs.push((
                "request-friend",
                json!([
                    my_id.to_hex(),
                    remote_id.to_hex(),
                    remote_addr.to_hex(),
                    remote_name,
                    remote_avatar,
                    remark
                ]),
            )),
            Event::RejectFriend(remote_id, my_id) => rpcs.push((
                "response-friend",
                json!([my_id.to_hex(), remote_id.to_hex()]),
            )),
            Event::AgreeFriend(remote_id, remote_addr, remote_name, remote_avatar, my_id) => rpcs
                .push((
                    "agree-friend",
                    json!([
                        my_id.to_hex(),
                        remote_id.to_hex(),
                        remote_addr.to_hex(),
                        remote_name,
                        remote_avatar
                    ]),
                )),
            Event::Message(remote_id, my_id, message) => rpcs.push((
                "message",
                json!([my_id.to_hex(), remote_id.to_hex(), message]),
            )),
        }

        Ok((rpcs, groups, layers))
    }
}
