use ed25519_dalek::{Keypair, KEYPAIR_LENGTH};

use crate::error::Error;

pub const DEFAULT_WS_ADDR: &'static str = "127.0.0.1:8080";

/// db save secret key.
pub fn db_sk_key() -> Vec<u8> {
    vec![1]
}

pub fn db_peer_list_key(password: String) -> Vec<u8> {
    (password + "peer_list").as_bytes().to_vec()
}

pub fn sk_encrypt(sk: Keypair, _password: String) -> Vec<u8> {
    // TODO password-salt => encrypt
    sk.to_bytes().to_vec()
}

pub fn sk_decrypt(data: Vec<u8>, _password: String) -> Result<Keypair, Error> {
    // TODO password-salt => decrypt
    let mut secret_bytes = [0u8; KEYPAIR_LENGTH];
    secret_bytes.copy_from_slice(&data[..]);
    Ok(Keypair::from_bytes(&secret_bytes).map_err(|_e| Error::SeedInvalid)?)
}
