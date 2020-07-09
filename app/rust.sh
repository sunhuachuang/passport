#### Default Current Machine
function current() {
    cargo build --release

    ## check now os.
}

#### Android ####
function android() {
    ## build library
    cargo build --release --target=i686-linux-android
    cargo build --release --target=armv7-linux-androideabi
    cargo build --release --target=aarch64-linux-android

    ## move to android directory
}

#### IOS ####
function ios() {
    echo 'WIP'
    ## build library
    #cargo build --release --target=i686-linux-android
    #cargo build --release --target=armv7-linux-androideabi

    ## move to ios directory
}

#### Linux ####
function linux() {
    echo 'WIP'
}

#### MacOS ####
function macos() {
    echo 'WIP'
}

#### Windows ####
function windows() {
    echo 'WIP'
}

#### Web ####
function web() {
    echo 'WIP'
}

if [ $# -eq 0 ]
then
    echo "Usage: ./rust.sh [OPTION]"
    echo "Rust dynamic library auto generator."
    echo ""
    echo "OPTION:"
    echo "  current    build current machine's library."
    echo "  all        build all versions libraries."
    echo "  android    only build for Android."
    echo "  ios        only build for IOS."
    echo "  linux      only build for Linux."
    echo "  macos      only build for MacOS."
    echo "  windows    only build for Windows."
    echo "  web        only build for web (wasm)."
else
    echo "Now is building: $1"
    cd ./rust
    $1
    cd ../
fi
