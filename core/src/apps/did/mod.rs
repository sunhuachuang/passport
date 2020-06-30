use ed25519_dalek::{Keypair, PublicKey, SecretKey};
//use serde_derive::{Deserialize, Serialize};
use sha3::{Digest, Sha3_256};
//use std::fmt::{Debug, Formatter, Result as FmtResult};
use tdn::primitive::PeerAddr;

pub(crate) mod rpc;

#[derive(Default, Clone, Copy)]
pub struct Did([u8; 32]);

#[derive(Default)]
pub struct Secret([u8; 32]);

#[derive(Default)]
pub struct Proof([u8; 32]);

pub struct User {
    id: Did,
    name: String,
    avator: String,
    bio: String,
    addr: PeerAddr,
}

impl Did {
    pub fn to_hex(&self) -> String {
        let mut s = String::with_capacity(self.0.len() * 2);
        s.extend(self.0.iter().map(|b| format!("{:02x}", b)));
        s
    }

    pub fn from_hex(s: impl ToString) -> Result<Self, ()> {
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

    pub fn new(id: Did, name: String, avator: String, bio: String, addr: PeerAddr) -> Self {
        Self {
            id,
            name,
            avator,
            bio,
            addr,
        }
    }
}

pub fn genereate_id(seed: &[u8]) -> (Did, Secret) {
    Default::default()
}

pub fn generate(
    name: String,
    avator: String,
    bio: String,
    addr: PeerAddr,
    seed: &[u8],
) -> (User, Secret) {
    let (did, sk) = genereate_id(seed);
    (User::new(did, name, avator, bio, addr), sk)
}

pub fn zkp_proof(peer_addr: &PeerAddr, m_id: &Did, sk: &Secret, r_id: &Did) -> Proof {
    Proof::default()
}

pub fn zkp_verify(proof: &Proof, peer_addr: &PeerAddr, r_id: &Did, sk: &Secret) -> bool {
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
    pub fn generate(name: String, addr: PeerAddr, seed: &[u8]) -> Result<MeId, ()> {
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
