{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.programs.hyprland;
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  options.programs.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };
  };
}
