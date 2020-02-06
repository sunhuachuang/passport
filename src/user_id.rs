pub struct UserId;
pub struct UserChallenge;
pub struct UserProve;

impl UserId {
    fn generate_id() -> UserId {
        UserId
    }

    fn challenge() -> UserChallenge {
        UserChallenge
    }

    fn prove(c: UserChallenge) -> UserProve {
        UserProve
    }

    fn verify(c: UserChallenge, p: UserProve) -> bool {
        true
    }
}
