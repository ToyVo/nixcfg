{ config, lib, pkgs, ... }:
let
  cfg = config.services.xserver.desktopManager;
  plasma6 = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf (plasma6.enable || cfg.plasma5.enable || cfg.plasma5.mobile.enable) {
    services = {
      xserver.enable = true;
      libinput.enable = true;
      displayManager.sddm = {
        enable = true;
        catppuccin.enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      kate
      kdePackages.sddm-kcm
    ];
  };
}
