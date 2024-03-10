{ lib, config, ... }:
let
  cfg = config.services.xserver.desktopManager;
in
{
  config = lib.mkIf (cfg.plasma6.enable || cfg.plasma5.enable || cfg.plasma5.mobile.enable) {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "qt";
    profiles.gui.enable = true;
  };
}
