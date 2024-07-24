{ lib, config, ... }:
let
  cfg = config.services.desktopManager.cosmic;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      displayManager.cosmic-greeter.enable = true;
      libinput.enable = true;
    };
    profiles.gui.enable = true;
  };
}
