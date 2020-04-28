use std::net::SocketAddr;

use tdn::async_std::io::Result;
use tdn::prelude::{GroupId, LayerReceiveMessage};

struct LayerBus;

impl LayerBus {
    pub async fn handle(ltype: LayerReceiveMessage) -> Result<()> {
        match ltype {
            // TODO
        }
    }

    pub async fn upper(gid: GroupId, bytes: Vec<u8>) -> Result<()> {}

    pub async fn lower(gid: GroupId, bytes: Vec<u8>) -> Result<()> {}

    pub async fn upper_join(gid: GroupId) -> Result<()> {}

    pub async fn lower_join(
        req_gid: GroupId,
        remote_gid: GroupId,
        uuid: u32,
        addr: SocketAddr,
        bytes: Vec<u8>,
    ) -> Result<()> {
    }

    pub async fn upper_join_result(remote_gid: GroupId, is_ok: bool) -> Result<()> {}

    pub async fn lower_join_result(
        req_gid: GroupId,
        remote_gid: GroupId,
        uuid: u32,
        is_ok: bool,
    ) -> Result<()> {
    }
}
