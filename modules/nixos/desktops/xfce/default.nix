{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.desktops.xfce.enable = lib.mkEnableOption "Enable Xfce";

  config = lib.mkIf cfg.desktops.xfce.enable {
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
      libinput.enable = true;
    };
    cd.packages.gui.enable = true;
  };
}
