{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.programs.bat;
in
{
  config = lib.mkIf cfg.enable {
    programs.bat = {
      themes = {
        catppuccin-frappe.src = "${inputs.catppuccin-bat}/themes/Catppuccin Frappe.tmTheme";
      };
      config.theme = "catppuccin-frappe";
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
    home.shellAliases = {
      cat = "bat -pp";
    };
  };
}
