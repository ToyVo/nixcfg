{ lib, config, ... }:
let
  cfg = config.cd;
  homeDirectory = "/var/root";
in
{
  imports = [ ../../../nixos/users/root/common.nix ];

  config = lib.mkIf cfg.users.toyvo.enable {
    users.users.root.home = lib.mkForce "/var/root";
    home-manager.users.root = {
      home.homeDirectory = lib.mkForce /var/root;
      home.sessionPath = [ "/opt/homebrew/bin" ];
      home.file.".hushlogin".text = "";
    };
  };
}

