use ed25519_dalek::{Keypair, PublicKey, Signature};
use serde_derive::{Deserialize, Serialize};
use tdn::primitive::PeerAddr;

use crate::group::{Friend, GroupId, Peer, UserId};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Event {
    pub from: UserId,
    pub to: UserId,
    pub msg: Message,
    sign: Signature,
}

impl Event {
    pub fn as_bytes(&self) -> Vec<u8> {
        bincode::serialize(&self).unwrap_or(vec![])
    }

    pub fn from_bytes(bytes: &Vec<u8>) -> Result<Event, bincode::Error> {
        bincode::deserialize::<Event>(bytes)
    }

    pub fn signed(from: UserId, to: UserId, msg: Message, keypair: &Keypair) -> Event {
        let sign = Peer::sign(&bincode::serialize(&msg).unwrap_or(vec![]), keypair);

        Event {
            from,
            to,
            msg,
            sign,
        }
    }

    pub fn verify(&self, user: &Peer) -> bool {
        let data = bincode::serialize(&self.msg).unwrap_or(vec![]);
        user.verify(&data, &self.sign)
    }

    pub fn new_by_apply_friend(
        to: UserId,
        my: Peer,
        friend: Friend,
        remark: String,
        keypair: &Keypair,
    ) -> Event {
        println!("DEBUG: New request event: from: {}, to: {}", friend.id, to);
        let from = friend.id.clone();
        let msg = Message::ApplyFriend(my, friend, remark);
        Self::signed(from, to, msg, keypair)
    }

    pub fn new_by_reply_friend_success(
        to: UserId,
        my: Peer,
        friend: Friend,
        keypair: &Keypair,
    ) -> Event {
        let from = friend.id.clone();
        let msg = Message::ReplyFriendSuccess(my, friend);
        Self::signed(from, to, msg, keypair)
    }

    pub fn new_by_reply_friend_failure(from: UserId, to: UserId, keypair: &Keypair) -> Event {
        Self::signed(from, to, Message::ReplyFriendFailure, keypair)
    }

    pub fn new_by_message(
        from: UserId,
        to: UserId,
        data_type: u32,
        data_value: String,
        data_time: String,
        keypair: &Keypair,
    ) -> Event {
        Self::signed(
            from.clone(),
            to.clone(),
            Message::Data(from, to, data_type, data_value, data_time),
            keypair,
        )
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Message {
    /// New a user: user_id, name, bio, avator, pk.
    UserNew(UserId, String, String, String, String, PublicKey),
    /// Edit user info: user_id, name, remark, bio, avator
    UserEdit(UserId, String, String, String, String, String),
    /// Deprecated use account. others will close it.
    UserReject(UserId),
    /// Make friend with other: from_user, from_user_info, remark.
    ApplyFriend(Peer, Friend, String),
    /// Make friend sucess: my_make_friend_user
    ReplyFriendSuccess(Peer, Friend),
    /// Make friend failure.
    ReplyFriendFailure,
    /// Close friend: one person, other person.
    FriendReject(UserId, UserId),
    /// Tell all friends I online: user_id, peer_addr.
    FriendOnline(UserId, PeerAddr),
    /// Tell all friends I offline.
    FriendOffline(UserId),
    /// New a Group: id, owner, name, bio, avator
    GroupNew(GroupId, UserId, String, String, String),
    /// Invate person to this Group: id, owner, name, bio, avator, sign.
    GroupInvate(GroupId, UserId, String, String, String, Signature),
    /// Reject someone from a group: id, rejected_user_id.
    GroupReject(GroupId, UserId),
    /// Message Data: from, to, type, value, time.
    Data(String, String, u32, String, String),
}
