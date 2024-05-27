{nh, nix-index-database, ...}: {config, ...}: {
  imports = [
    ./alias-system-apps.nix
    ../../nixos/profiles/common.nix
    ../../nixos/users/common.nix
    nh.nixDarwinModules.prebuiltin
    nix-index-database.darwinModules.nix-index
  ];
  options = {};
  config = {};
}
