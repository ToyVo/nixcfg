{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.desktops.hyprland.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf cfg.desktops.hyprland.enable {
    programs.hyprland.enable = true;
    cd.packages.gui.enable = true;
  };
}
