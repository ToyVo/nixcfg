{ ... }:
{
  imports = [
    ./darwin.nix
  ];
  homebrew.taps = [
    "mongodb/brew"
  ];
  homebrew.casks = [
    "slack"
    "docker"
  ];
  homebrew.brews = [
    "mongodb-community"
    "mongodb-community-shell"
    "brotli"
    "c-ares"
    "ca-certificates"
    "icu4c"
    "libnghttp2"
    "libuv"
    "openssl"
    "node"
    "mongosh"
    "mongodb-database-tools"
  ];
}
