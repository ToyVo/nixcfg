{
  config,
  lib,
  pkgs,
  ...
}:
let
  plasma5 = config.services.xserver.desktopManager.plasma5;
  plasma6 = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf (plasma6.enable || plasma5.enable || plasma5.mobile.enable) (
    lib.mkMerge [
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
      (lib.mkIf (plasma5.enable || plasma5.mobile.enable) {
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
    ]
  );
}
