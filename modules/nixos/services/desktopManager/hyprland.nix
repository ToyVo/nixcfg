{ config, lib, ... }:
let
  cfg = config.programs.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    profiles.gui.enable = true;
  };
}
