use std::net::SocketAddr;

use tdn::async_std::io::Result;
use tdn::async_std::sync::{Arc, RwLock};
use tdn::prelude::{GroupId, LayerReceiveMessage};

use crate::storage::LocalStorage;

pub struct LayerBus(Arc<RwLock<LocalStorage>>);

impl LayerBus {
    pub fn new(ls: Arc<RwLock<LocalStorage>>) -> Self {
        Self(ls)
    }

    pub async fn handle(&mut self, _ltype: LayerReceiveMessage) -> Result<()> {
        //match ltype {
        // TODO
        //}

        Ok(())
    }

    async fn _upper(_gid: GroupId, _bytes: Vec<u8>) -> Result<()> {
        Ok(())
    }

    async fn _lower(_gid: GroupId, _bytes: Vec<u8>) -> Result<()> {
        Ok(())
    }

    async fn _upper_join(_gid: GroupId) -> Result<()> {
        Ok(())
    }

    async fn _lower_join(
        _req_gid: GroupId,
        _remote_gid: GroupId,
        _uuid: u32,
        _addr: SocketAddr,
        _bytes: Vec<u8>,
    ) -> Result<()> {
        Ok(())
    }

    async fn _upper_join_result(_remote_gid: GroupId, _is_ok: bool) -> Result<()> {
        Ok(())
    }

    async fn _lower_join_result(
        _req_gid: GroupId,
        _remote_gid: GroupId,
        _uuid: u32,
        _is_ok: bool,
    ) -> Result<()> {
        Ok(())
    }
}
