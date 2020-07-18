use ed25519_dalek::{Keypair, PublicKey, SecretKey};
use sha3::{Digest, Sha3_256};
//use std::fmt::{Debug, Formatter, Result as FmtResult};
use tdn::async_std::{
    io::Result,
    sync::{Arc, RwLock},
};
use tdn::prelude::PeerAddr;

use crate::storage::Storage;

pub(crate) mod group;
pub(crate) mod rpc;

#[derive(Default, Clone, Copy, Serialize, Deserialize)]
pub struct Did([u8; 32]);

#[derive(Default)]
pub struct Secret([u8; 32]);

#[derive(Default)]
pub struct Proof([u8; 32]);

#[derive(Serialize, Deserialize)]
pub struct User {
    id: Did,
    pub name: String,
    pub avatar: String,
}

impl Did {
    pub fn as_bytes(&self) -> &[u8] {
        &self.0
    }

    pub fn to_hex(&self) -> String {
        let mut s = String::with_capacity(self.0.len() * 2);
        s.extend(self.0.iter().map(|b| format!("{:02x}", b)));
        s
    }

    pub fn from_hex(s: impl ToString) -> std::result::Result<Self, ()> {
        let s = s.to_string();
        if s.len() != 64 {
            return Err(());
        }

        let mut value = [0u8; 32];

        for i in 0..(s.len() / 2) {
            let res = u8::from_str_radix(&s[2 * i..2 * i + 2], 16).map_err(|_e| ())?;
            value[i] = res;
        }

        Ok(Self(value))
    }
}

impl User {
    pub fn id(&self) -> &Did {
        &self.id
    }

    pub fn hex_id(&self) -> String {
        self.id.to_hex()
    }

    pub fn new(id: Did, name: String, avatar: String) -> Self {
        Self { id, name, avatar }
    }

    pub async fn load(did: &Did, db: &Arc<RwLock<Storage>>) -> Option<Self> {
        db.read().await.ls().read::<User>(did.as_bytes())
    }

    pub async fn save(&self, db: &Arc<RwLock<Storage>>) -> Result<()> {
        db.read()
            .await
            .ls()
            .write(self.id.as_bytes().to_vec(), self)
    }

    pub async fn save_sk(&self, sk: Secret) {
        todo!()
    }
}

pub fn genereate_id(seed: &[u8]) -> (Did, Secret) {
    let mut sha = Sha3_256::new();
    sha.input(seed);

    let mut did = [0u8; 32];
    did.copy_from_slice(&sha.result()[..]);

    (Did(did), Secret([0u8; 32]))
}

pub fn generate(name: String, avatar: String, seed: &[u8]) -> (User, Secret) {
    let (did, sk) = genereate_id(seed);
    (User::new(did, name, avatar), sk)
}

pub fn _zkp_proof(peer_addr: &PeerAddr, m_id: &Did, sk: &Secret, r_id: &Did) -> Proof {
    Proof::default()
}

pub fn _zkp_verify(proof: &Proof, peer_addr: &PeerAddr, r_id: &Did, sk: &Secret) -> bool {
    true
}

// old
pub struct MeId {
    id: String,
    name: String,
    addr: PeerAddr,
    keypair: Keypair,
}

impl MeId {
    pub fn _generate(name: String, addr: PeerAddr, seed: &[u8]) -> std::result::Result<MeId, ()> {
        let mut secret_bytes = [0u8; 32];
        let mut sha = Sha3_256::new();
        sha.input(seed);
        secret_bytes.copy_from_slice(&sha.result()[..]);
        let secret = SecretKey::from_bytes(&secret_bytes).map_err(|_e| ())?;
        let public: PublicKey = (&secret).into();
        let id = bs58::encode(public.as_bytes()).into_string();
        let keypair = Keypair { secret, public };

        Ok(MeId {
            id,
            name,
            addr,
            keypair,
        })
    }
}
