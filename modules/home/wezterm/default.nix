{ lib, config, pkgs, ... }:
let
  cfg = config.programs.wezterm;
in
{
  config = lib.mkIf cfg.enable {
    programs.wezterm.extraConfig = ''
      local wezterm = require("wezterm");
      local config = wezterm.config_builder();
      config.font = wezterm.font {
        family = "MonaspiceNe Nerd Font",
        harfbuzz_features = {'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'},
      };
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
