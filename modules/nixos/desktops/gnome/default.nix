{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.gnome.enable = lib.mkEnableOption "Enable Gnome";

  config = lib.mkIf cfg.gnome.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome-extension-manager
    ];
    cd.packages.gui.enable = true;
  };
}
