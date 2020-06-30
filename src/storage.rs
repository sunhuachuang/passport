//use ed25519_dalek::Keypair;
use std::path::PathBuf;

use tdn::async_std::io::Result;
//use tdn::prelude::PeerAddr;
//use tdn::storage::{open_absolute_db, LocalDB};

//use crate::error::new_io_error;
//use crate::user_id::{PeerList, User, UserId};

//const USER_KEY: [u8; 1] = [0];
//const SECRET_KEY: [u8; 1] = [1];
//const PEERS_KEY: [u8; 1] = [2];

pub struct LocalStorage(PathBuf);

impl LocalStorage {
    pub fn init(path: PathBuf) -> Result<Self> {
        // TODO check path;

        Ok(LocalStorage(path))
    }

    // pub fn load_users(&self) -> Vec<UserId> {
    //     vec![]
    // }

    // pub fn load_user(&self, addr: PeerAddr, _pw: String, user_id: &UserId) -> Result<PeerList> {
    //     let db = UserDB(open_absolute_db(self.0.clone(), user_id)?);
    //     let mut user = db.load_user().ok_or(new_io_error("user not found!"))?;
    //     let secret = db.load_key().ok_or(new_io_error("secret key not found!"))?;

    //     // TODO decrypt secret.

    //     let keypair = Keypair::from_bytes(&secret).map_err(|_e| new_io_error("keypair failure"))?;
    //     info!("{} loaded", user_id);

    //     user.load_transfer(keypair);
    //     PeerList::load(db, addr, user)
    // }

    // pub fn add_user(&self, addr: PeerAddr, _pw: String, user: User) -> Result<PeerList> {
    //     // check user is exsit. if exsit.

    //     // if not exsit.
    //     let db = UserDB(open_absolute_db(self.0.clone(), &user.id)?);
    //     let secret = user.keypair.to_bytes().to_vec();

    //     // TODO encrypt secret.

    //     db.init(&user, secret)?;
    //     PeerList::load(db, addr, user)
    // }

    // pub fn del_user(&self, _pw: String, user_id: &UserId) -> Result<()> {
    //     let db = UserDB(open_absolute_db(self.0.clone(), &user_id)?);
    //     let _secret = db.load_key().ok_or(new_io_error("secret key not found!"));
    //     // TODO check password is save.

    //     Ok(())
    // }
}

// pub struct UserDB(LocalDB);

// impl UserDB {
//     pub fn init(&self, user: &User, secret: Vec<u8>) -> Result<()> {
//         self.0.write(SECRET_KEY.to_vec(), &secret)?;
//         //self.0.write(PEERS_KEY, &vec![])?;
//         self.save_user(user)
//     }

//     pub fn load_key(&self) -> Option<Vec<u8>> {
//         self.0.read::<Vec<u8>>(&SECRET_KEY)
//     }

//     pub fn load_user(&self) -> Option<User> {
//         self.0.read::<User>(&USER_KEY)
//     }

//     // pub fn load_peers(&self) -> Result<Vec<Peer>> {}

//     // pub fn load_groups(&self) {}

//     // pub fn load_blacks(&self) {}

//     pub fn save_user(&self, user: &User) -> Result<()> {
//         self.0.write(USER_KEY.to_vec(), &user.save_transfer())
//     }

//     // pub fn add_peer(&self, peer: &Peer) -> Result<()> {
//     //     let id = peer.id().vec();
//     //     // load peers key & append.

//     //     // save peer.
//     //     self.0.write(&id, peer)
//     // }

//     // pub fn del_peer(&self, id: &UserId) -> Result<()> {
//     //     // load peers key & del

//     //     // delete peer.
//     //     self.0.delete(&id.vec())
//     // }

//     pub fn add_group() {}

//     pub fn add_black_peer() {}

//     pub fn del_black_peer() {}

//     pub fn add_black_group() {}

//     pub fn del_black_group() {}
// }
