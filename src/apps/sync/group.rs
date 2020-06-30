use blake2::Blake2s;
use ed25519_dalek::{Keypair, PublicKey, SecretKey, Signature, KEYPAIR_LENGTH};
use serde_derive::{Deserialize, Serialize};
use sha3::{Digest, Sha3_256};
use std::collections::HashMap;
use tdn::async_std::io::Result;
use tdn::prelude::*;

use crate::error::new_io_error;
use crate::event::Event;
use crate::storage::UserDB;

pub type UserId = String;
pub type GroupId = String;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Peer {
    gid: GroupId,
    psk: PublicKey,
    sig: Signature,
    pub par: PeerAddr,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct User {
    pub id: UserId,
    pub name: String,
    pub avator: String,
    pub bio: String,
    pub keypair: Keypair,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Friend {
    pub id: UserId,
    pub name: String,
    pub avator: String,
    pub bio: String,
}

impl User {
    pub fn init(name: String, avator: String, bio: String, seed: String) -> Result<Self> {
        let keypair = if seed.len() != 0 {
            let mut secret_bytes = [0u8; 32];
            let mut sha = Sha3_256::new();
            sha.input(seed.as_bytes());
            secret_bytes.copy_from_slice(&sha.result()[..]);
            let sk = SecretKey::from_bytes(&secret_bytes)
                .map_err(|_e| new_io_error("generate secret failure"))?;
            let pk: PublicKey = (&sk).into();
            let keypair = Keypair {
                secret: sk,
                public: pk,
            };
            keypair
        } else {
            Keypair::generate(&mut rand::thread_rng())
        };

        Ok(User {
            id: Peer::generate_id(&keypair.public),
            name,
            avator,
            bio,
            keypair,
        })
    }

    pub fn to_friend(&self) -> Friend {
        Friend {
            id: self.id.clone(),
            name: self.name.clone(),
            avator: self.avator.clone(),
            bio: self.bio.clone(),
        }
    }

    pub fn load_transfer(&mut self, keypair: Keypair) {
        self.keypair = keypair;
    }

    pub fn save_transfer(&self) -> User {
        User {
            id: self.id.clone(),
            name: self.name.clone(),
            avator: self.avator.clone(),
            bio: self.bio.clone(),
            keypair: Keypair::from_bytes(&[0u8; KEYPAIR_LENGTH]).unwrap(),
        }
    }
}

impl Peer {
    #[inline]
    pub fn generate_id(pk: &PublicKey) -> UserId {
        let mut sha = Sha3_256::new();
        sha.input(pk.as_bytes());
        let one_bytes = sha.result();

        let mut blake = Blake2s::new();
        blake.input(one_bytes);
        let two_bytes = blake.result();

        format!("Y{}", bs58::encode(two_bytes).into_string())
    }

    pub fn id(&self) -> UserId {
        Peer::generate_id(&self.psk)
    }

    pub fn verify(&self, data: &[u8], sig: &Signature) -> bool {
        self.psk.verify(data, sig).is_ok()
    }

    pub fn sign(data: &[u8], sk: &Keypair) -> Signature {
        sk.sign(data)
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct JoinType {
    gid: GroupId,
    uid: GroupId,
    sig: Signature,
}

impl JoinType {
    #[inline]
    pub fn default() -> Vec<u8> {
        vec![]
    }
}

pub struct PeerList {
    db: UserDB,
    my: User,
    addr: PeerAddr,
    groups: HashMap<GroupId, PublicKey>,
    friends: HashMap<UserId, Peer>,
    onlines: HashMap<UserId, PeerAddr>,
    black_groups: Vec<GroupId>,
    black_users: Vec<UserId>,
    request_friends: HashMap<UserId, Peer>,
}

/// Load and init PeerList.
impl PeerList {
    pub fn load(db: UserDB, addr: PeerAddr, my: User) -> Result<PeerList> {
        //let friends = db.load_peers()?;

        Ok(PeerList {
            db,
            my,
            addr,
            groups: HashMap::new(),
            friends: HashMap::new(),
            onlines: HashMap::new(),
            black_groups: vec![],
            black_users: vec![],
            request_friends: HashMap::new(),
        })
    }
}

/// Operation about friends.
impl PeerList {
    /// build a apply for friend request event.
    pub fn apply_friend(&mut self, user_id: UserId, remark: String) -> Event {
        let me = self.sign_peer(user_id.clone());
        let friend = self.my.to_friend();
        // save to prove this request if from me.
        self.request_friends.insert(user_id.clone(), me.clone());
        Event::new_by_apply_friend(user_id, me, friend, remark, &self.my.keypair)
    }

    /// build a reply to request friend event.
    pub fn reply_friend(&mut self, user_id: UserId, is_ok: bool) -> Event {
        if let Some(peer) = self.request_friends.remove(&user_id) {
            if is_ok {
                self.friends.insert(user_id.clone(), peer);
                let me = self.sign_peer(user_id.clone());
                let friend = self.my.to_friend();
                return Event::new_by_reply_friend_success(user_id, me, friend, &self.my.keypair);
            }
        }

        Event::new_by_reply_friend_failure(self.my.id.clone(), user_id, &self.my.keypair)
    }

    /// build a close friendship notify event.
    //pub fn close_friend(&mut self) -> Event {}

    /// build a online message to friends event.
    //pub fn online_friend(&mut self) -> Event {}

    /// build a outline message to friends event.
    //pub fn outline_friend(&mut self) -> Event {}

    /// build a message to friend event.
    pub fn message_friend(
        &mut self,
        user_id: UserId,
        data_type: u32,
        data_value: String,
        data_time: String,
    ) -> Option<(PeerAddr, Event)> {
        if let Some(user) = self.friends.get(&user_id) {
            Some((
                user.par,
                Event::new_by_message(
                    self.my.id.clone(),
                    user_id,
                    data_type,
                    data_value,
                    data_time,
                    &self.my.keypair,
                ),
            ))
        } else {
            None
        }
    }

    /// receive a apply for friend.
    pub fn friend_apply(&mut self, user_id: UserId, peer: Peer) {
        self.request_friends.insert(user_id, peer);
    }

    /// receive a reply friend application. return it is or not my application.
    pub fn friend_reply(&mut self, user_id: UserId, maybe_peer: Option<Peer>) -> bool {
        if let Some(_) = self.request_friends.remove(&user_id) {
            if let Some(peer) = maybe_peer {
                self.friends.insert(user_id.clone(), peer);
            }
            true
        } else {
            false
        }
    }

    /// receive a close friendship.
    pub fn friend_close(&mut self) {}

    /// receive a online message from friend.
    pub fn friend_online(&mut self) {}

    /// receive a outline message from friend.
    pub fn friend_outline(&mut self) {}
}

impl PeerList {
    pub fn addr(&self) -> PeerAddr {
        self.addr.clone()
    }

    pub fn sign_peer(&self, user_id: UserId) -> Peer {
        Peer {
            psk: self.my.keypair.public,
            sig: self.my.keypair.sign(user_id.as_bytes()),
            par: self.addr,
            gid: user_id,
        }
    }

    pub fn friends_join_iter<'a>(&self) -> Vec<(PeerAddr, Vec<u8>)> {
        self.friends
            .iter()
            .map(|(uid, u)| {
                (
                    u.par.clone(),
                    bincode::serialize(&JoinType {
                        gid: u.gid.clone(),
                        uid: uid.clone(),
                        sig: u.sig.clone(),
                    })
                    .unwrap_or(vec![]),
                )
            })
            .collect()
    }

    // pub fn peer_join(&mut self, peer_addr: PeerAddr, data: Vec<u8>) -> (bool, bool) {
    //     if self.black_peers.contains(&peer_addr) {
    //         return (false, true); // black peer, force close it.
    //     }

    //     let join_type_result: Result<JoinType, _> = bincode::deserialize(&data);
    //     if join_type_result.is_err() {
    //         return (false, false);
    //     }

    //     let JoinType { gid, uid, sig } = join_type_result.unwrap();

    //     if self.black_groups.contains(&gid) || self.black_users.contains(&uid) {
    //         return (false, true); // black group or user, force close it.
    //     }

    //     if self
    //         .friends
    //         .get_mut(&uid)
    //         .map(|u| {
    //             u.par = peer_addr;
    //             u.sar = addr;
    //         })
    //         .is_none()
    //     {
    //         return (false, false);
    //     }

    //     self.onlines.insert(peer_addr, uid);

    //     (true, false)
    // }

    pub fn peer_leave(&mut self, peer_addr: &PeerAddr) -> bool {
        // TODO need better.
        let mut is_notify = false;
        let mut user_id = "".to_owned();
        for (uid, addr) in self.onlines.iter_mut() {
            if addr == peer_addr {
                user_id = uid.clone();
                is_notify = true;
            }
        }
        self.onlines.remove(&user_id);
        is_notify
    }

    pub fn add_group(&mut self) {}

    pub fn reject_group(&mut self) {}
}
