{ lib, config, ... }:
let
  cfg = config.cdcfg.hyprland;
in
{
  options.cdcfg.hyprland.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
  };
}
