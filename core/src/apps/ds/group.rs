use postcard::{from_bytes, to_allocvec};
use tdn::async_std::io::Result;

use crate::error::new_io_error;
use crate::group::Event as BaseEvent;

use super::super::{AppSymbol, EventResult};

#[derive(Serialize, Deserialize)]
pub enum Event {}

impl Event {
    pub fn to_event(&self) -> BaseEvent {
        BaseEvent {
            app: AppSymbol::Ds,
            event: to_allocvec(self).unwrap_or(vec![]),
        }
    }

    pub fn handle(bytes: &[u8]) -> Result<EventResult> {
        let _event = from_bytes(bytes).map_err(|_| new_io_error("serialize event error"))?;

        Ok((vec![], vec![], vec![]))
    }
}
