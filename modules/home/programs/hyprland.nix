{ config, lib, ... }:
let
  cfg = config.programs.hyprland;
in
{
  options.programs.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };
  };
}
