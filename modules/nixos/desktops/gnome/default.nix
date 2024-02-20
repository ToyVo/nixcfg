{ lib, config, pkgs, ... }:
let
  cfg = config.services.xserver.desktopManager.gnome;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome-extension-manager
    ];
    profiles.gui.enable = true;
  };
}
