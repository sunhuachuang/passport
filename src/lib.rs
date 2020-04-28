use std::ffi::CString;
use std::os::raw::c_char;
use tdn::async_std::task;

mod error;
mod event;
mod group;
mod primitives;
mod rpc;
mod rpc_common;
mod rpc_user;
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
