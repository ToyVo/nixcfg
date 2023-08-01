{ lib, config, ... }:
let
  cfg = config.cdcfg.plasma;
in
{
  options.cdcfg.plasma.enable = lib.mkEnableOption "Enable plasma";
  options.cdcfg.plasma.mobile.enable = lib.mkEnableOption "Enable plasma mobile";

  config = lib.mkIf (cfg.enable || cfg.mobile.enable) {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = cfg.enable;
      desktopManager.plasma5.mobile.enable = cfg.mobile.enable;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "qt";
  };
}
