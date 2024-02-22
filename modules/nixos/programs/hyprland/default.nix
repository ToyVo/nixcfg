{ lib, config, inputs, ... }:
let
  cfg = config.programs.hyprland;
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    profiles.gui.enable = true;
  };
}
