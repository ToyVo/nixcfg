{ lib, config, pkgs, ... }:
let
  cfg = config.services.xserver.desktopManager;
  plasma6 = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf (plasma6.enable || cfg.plasma5.enable || cfg.plasma5.mobile.enable) {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryProgram = pkgs.pinentry-qt;
    profiles.gui.enable = true;
    environment.systemPackages = with pkgs; [
      kate
    ];
  };
}
