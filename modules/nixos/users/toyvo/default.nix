{ lib, pkgs, config, ... }:
let
  cfg = config.cd;
in
{
  imports = [ ./common.nix ];

  config = lib.mkIf cfg.users.toyvo.enable {
    users.users.${cfg.users.toyvo.name} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
    };
    home-manager.users.${cfg.users.toyvo.name} = {
      services.keybase.enable = true;
      services.kbfs.enable = true;
    };
  };
}
