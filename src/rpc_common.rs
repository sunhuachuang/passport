use tdn::prelude::{PeerAddr, RpcParam};
use tdn::primitive::json;

use crate::group::{Friend, PeerList, User, UserId};

pub enum RpcInfo {
    ApplyFriend(Friend, PeerAddr, String),
    ReplyFriend(Option<Friend>, UserId, PeerAddr),
    FriendOnline(String),
    FriendOffline,
    Message(UserId, u32, String, String),
}

impl RpcInfo {
    pub fn json(self) -> RpcParam {
        match self {
            RpcInfo::ApplyFriend(info, peer_addr, remark) => raw_response(
                "apply-friend",
                vec![
                    info.id,
                    info.name,
                    info.avator,
                    info.bio,
                    peer_addr.to_hex(),
                    remark,
                ],
            ),
            RpcInfo::ReplyFriend(info_some, user_id, peer_addr) => raw_response(
                "reply-friend",
                if let Some(info) = info_some {
                    vec![
                        "1".to_owned(),
                        info.id,
                        info.name,
                        info.avator,
                        info.bio,
                        peer_addr.to_hex(),
                    ]
                } else {
                    vec!["0".to_owned(), user_id]
                },
            ),
            RpcInfo::Message(from, data_type, data_value, data_time) => raw_response(
                "message",
                vec![from, format!("{}", data_type), data_value, data_time],
            ),
            _ => Default::default(),
        }
    }
}

fn raw_response(method: &str, params: Vec<String>) -> RpcParam {
    json!({
        "jsonrpc": "2.0",
        "result": {
            "method": method,
            "params": params,
        }
    })
}

pub fn response(method: &str, params: Vec<RpcParam>) -> RpcParam {
    json!({
        "method": method,
        "params": params
    })
}

pub fn success_response(method: &str) -> RpcParam {
    response("success", vec![RpcParam::String(method.to_owned())])
}

pub fn failure_response(method: &str, reason: &str) -> RpcParam {
    response(
        "success",
        vec![
            RpcParam::String(method.to_owned()),
            RpcParam::String(reason.to_owned()),
        ],
    )
}
