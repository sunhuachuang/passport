#[macro_use]
extern crate log;

#[macro_use]
extern crate serde;

use std::ffi::CString;
use std::os::raw::c_char;
use tdn::async_std::task;

mod apps;
mod error;
mod group;
mod layer;
mod primitives;
mod rpc;
mod server;
mod storage;

#[no_mangle]
pub extern "C" fn start(db_path: *mut c_char) {
    unsafe {
        let cs_path = CString::from_raw(db_path);
        let s_path = cs_path.into_string().unwrap_or("./tdn".to_owned());

        let _ = task::block_on(server::start(s_path));
    }
}
