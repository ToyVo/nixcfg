{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.wezterm.enable = lib.mkEnableOption "Enable wezterm";

  config = lib.mkIf cfg.packages.wezterm.enable {
    programs.wezterm.enable = true;
    programs.wezterm.extraConfig = ''
      local wezterm = require("wezterm");
      local config = wezterm.config_builder();
      config.font = wezterm.font_with_fallback({"Monaspace Neon", "Symbols Nerd Font"});
      config.color_scheme = "Gruvbox Dark (Gogh)";
      config.initial_rows = 30;
      config.initial_cols = 120;
      config.window_background_opacity = 0.9;
      config.hide_tab_bar_if_only_one_tab = true;
      config.audible_bell = "Disabled";
      config.enable_kitty_keyboard = true;
      config.default_prog = { '${pkgs.fish}/bin/fish' };
      return config;
    '';
  };
}
