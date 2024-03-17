{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.programs.rio;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."rio/config.toml".text = ''
      theme = 'catppuccin-frappe'
      [window]
      width = 1200
      height = 800
      [shell]
      program = '${pkgs.nushell}/bin/nu'
      args = []
    '';

    xdg.configFile."rio/themes/catppuccin-frappe.toml".source = "${inputs.catppuccin-rio}/catppuccin-frappe.toml";
  };
}
