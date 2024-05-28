{ config, lib, ... }:
let
  cfg = config.services.xserver.desktopManager.xfce;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
      };
      libinput.enable = true;
    };
    profiles.gui.enable = true;
  };
}
