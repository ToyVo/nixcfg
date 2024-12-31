{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xserver.desktopManager;
  plasma6 = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf (plasma6.enable || cfg.plasma5.enable || cfg.plasma5.mobile.enable) (lib.mkMerge [
    {
      services = {
        xserver.enable = true;
        libinput.enable = true;
        displayManager.sddm.enable = true;
      };
      environment.systemPackages = with pkgs; [
        kate
      ];
    }
    (lib.mkIf (cfg.plasma5.enable || cfg.plasma5.mobile.enable) {
      catppuccin.sddm.enable = false;
      environment.systemPackages = with pkgs; [
        libsForQt5.sddm-kcm
      ];
    })
    (lib.mkIf plasma6.enable {
      catppuccin.sddm.enable = true;
      environment.systemPackages = with pkgs; [
        kdePackages.sddm-kcm
      ];
    })
  ]);
}
