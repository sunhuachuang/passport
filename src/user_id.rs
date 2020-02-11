use ed25519_dalek::{Keypair, PublicKey, SecretKey, Signature};
use serde_derive::{Deserialize, Serialize};
use sha3::{Digest, Sha3_256};
use std::fmt::{Debug, Formatter, Result as FmtResult};
use tdn::primitive::PeerAddr;

pub struct MeId {
    id: String,
    name: String,
    addr: PeerAddr,
    sign: Signature,
    keypair: Keypair,
}

pub struct UserId {
    pub id: String,
    pub name: String,
    pub addr: PeerAddr,
}

#[derive(Deserialize, Serialize)]
pub struct UserHandshake {
    id: String,
    name: String,
    addr: PeerAddr,
    sign: Signature,
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
        let content = bincode::serialize(&(&id, &name, &addr)).map_err(|_| ())?;
        let sign = keypair.sign(&content);

        Ok(MeId {
            id,
            name,
            addr,
            sign,
            keypair,
        })
    }

    pub fn handshake(&self) -> UserHandshake {
        UserHandshake {
            id: self.id.clone(),
            name: self.name.clone(),
            addr: self.addr.clone(),
            sign: self.sign.clone(),
        }
    }
}

impl UserHandshake {
    pub fn verify(self, addr: &PeerAddr) -> Result<UserId, ()> {
        if &self.addr != addr {
            return Err(());
        }
        let content = bincode::serialize(&(&self.id, &self.name, &self.addr)).map_err(|_| ())?;
        let pk_bytes = bs58::decode(&self.id).into_vec().map_err(|_e| ())?;
        let pk = PublicKey::from_bytes(&pk_bytes).map_err(|_e| ())?;
        if pk.verify(&content, &self.sign).is_ok() {
            let UserHandshake {
                id,
                name,
                addr,
                sign,
            } = self;

            return Ok(UserId { id, name, addr });
        }
        return Err(());
    }
}

impl Debug for MeId {
    fn fmt(&self, f: &mut Formatter) -> FmtResult {
        write!(
            f,
            "Id: {}, Name: {}, Addr: {}",
            self.id,
            self.name,
            self.addr.short_show()
        )
    }
}

impl Debug for UserId {
    fn fmt(&self, f: &mut Formatter) -> FmtResult {
        write!(
            f,
            "Id: {}, Name: {}, Addr: {}",
            self.id,
            self.name,
            self.addr.short_show()
        )
    }
}
