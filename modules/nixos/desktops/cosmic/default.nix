{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.desktops.cosmic.enable = lib.mkEnableOption "Enable cosmic";

  config = lib.mkIf cfg.desktops.cosmic.enable {
    services.xserver = {
      enable = true;
      # displayManager.cosmic-greeter.enable = true;
      # desktopManager.cosmic.enable = true;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "gnome3";
    cd.packages.gui.enable = true;
  };
}

