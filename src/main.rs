#[macro_use]
extern crate log;

use tdn::async_std::{io::Result, task};

mod apps;
mod error;
mod group;
mod layer;
mod primitives;
mod rpc;
mod server;
mod storage;

fn main() -> Result<()> {
    let db_path = ".tdn".to_owned();

    task::block_on(server::start(db_path))
}
