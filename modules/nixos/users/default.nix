{ lib, config, ... }:
let
  cfg = config.userPresets;
in
{
  imports = [ ./common.nix ];

  config = {
    users.users.${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
    };
    users.users.${cfg.chloe.name} = lib.mkIf cfg.chloe.enable {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$3qj7b7.lXJ2wiK29g9njQ1$Dn.dhmjQvPSkmdtHbA.2qEDl3eUnMeaawAW84X0/5i0";
    };
    users.extraGroups = lib.mkIf cfg.toyvo.enable {
      podman = lib.mkIf config.containerPresets.podman.enable { members = [ cfg.toyvo.name ]; };
    };
  };
}
