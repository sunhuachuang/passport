pub fn new_io_error(info: &str) -> std::io::Error {
    std::io::Error::new(std::io::ErrorKind::Other, info)
}

#[derive(Debug)]
pub enum Error {
    SeedInvalid,
    AvatorInvalid,
    FileIoError,
    NetIoError,
}
