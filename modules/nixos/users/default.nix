{ lib, config, ... }:
let
  cfg = config.userPresets.toyvo;
in
{
  imports = [ ./common.nix ];

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
    };
    users.extraGroups.docker.members = [ cfg.name ];
  };
}
