{ lib, config, pkgs, ... }:
let
  cfg = config.cdcfg.xfce;
in
{
  options.cdcfg.xfce.enable = lib.mkEnableOption "Enable Xfce";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
      libinput.enable = true;
    };
  };
}
