{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  imports = [ ../../../nixos/users/root/common.nix ];

  config = {
    users.users.root.home = lib.mkForce "/var/root";
    home-manager.users.root = {
      home.homeDirectory = lib.mkForce /var/root;
    };
  };
}

