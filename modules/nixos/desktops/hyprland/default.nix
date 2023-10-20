{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.hyprland.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf cfg.hyprland.enable {
    programs.hyprland.enable = true;
    cd.packages.gui.enable = true;
  };
}
