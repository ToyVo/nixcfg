{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.xfce.enable = lib.mkEnableOption "Enable Xfce";

  config = lib.mkIf cfg.xfce.enable {
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
      libinput.enable = true;
    };
    cd.packages.gui.enable = true;
  };
}
