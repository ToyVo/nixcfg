{ lib, config, ... }:
let
  cfg = config.cd;
  homeDirectory = "/Users/${cfg.users.toyvo.name}";
in
{
  imports = [ ../../../nixos/users/toyvo/common.nix ];

  config = lib.mkIf cfg.users.toyvo.enable {
    users.users.${cfg.users.toyvo.name}.home = lib.mkForce homeDirectory;
    home-manager.users.${cfg.users.toyvo.name} = {
      home.homeDirectory = lib.mkForce homeDirectory;
      home.file.".hushlogin".text = "";
    };
  };
}
