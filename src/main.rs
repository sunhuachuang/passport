use tdn::async_std::{io::Result, task};

mod error;
mod event;
mod group;
mod primitives;
mod rpc;
mod rpc_common;
mod rpc_user;
mod server;
mod storage;

fn main() -> Result<()> {
    let db_path = ".tdn".to_owned();

    task::block_on(server::start(db_path))
}
