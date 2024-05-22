{ lib, config, pkgs, ... }:
let
  cfg = config.services.xserver.desktopManager;
  plasma6 = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf (plasma6.enable || cfg.plasma5.enable || cfg.plasma5.mobile.enable) {
    services = {
      xserver.enable = true;
      libinput.enable = true;
      displayManager.sddm.enable = true;
      fwupd.enable = true;
    };
    profiles.gui.enable = true;
    environment.systemPackages = with pkgs; [
      kate
      aha
      pciutils
      clinfo
      glxinfo
      vulkan-tools
      fwupd
    ];
    # TODO: Can be removed when reaching nixos-unstable https://nixpk.gs/pr-tracker.html?pr=296866
    programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;
  };
}
