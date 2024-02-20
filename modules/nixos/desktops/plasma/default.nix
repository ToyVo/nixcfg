{ lib, config, ... }:
let
  cfg = config.services.xserver.desktopManager.plasma5;
in
{
  config = lib.mkIf (cfg.enable || cfg.mobile.enable) {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "qt";
    profiles.gui.enable = true;
  };
}
