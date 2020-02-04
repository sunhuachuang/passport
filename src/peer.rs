use tdn::traits::peer::Peer as PeerTrait;

pub struct Peer;

impl PeerTrait for Peer {
    type PublicKey = Vec<u8>;
    type SecretKey = Vec<u8>;
    type Signature = Vec<u8>;

    fn sign(
        _sk: &Self::SecretKey,
        _msg: &Vec<u8>,
    ) -> Result<Self::Signature, Box<dyn std::error::Error>> {
        Ok(vec![1, 2, 3])
    }

    fn verify(_pk: &Self::PublicKey, _msg: &Vec<u8>, sign: &Self::Signature) -> bool {
        sign == &vec![1, 2, 3]
    }

    fn hex_public_key(pk: &Self::PublicKey) -> String {
        "TODO".to_owned()
    }
}
