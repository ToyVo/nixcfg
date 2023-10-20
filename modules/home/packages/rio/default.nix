{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.rio.enable = lib.mkEnableOption "Enable rio";

  config = lib.mkIf cfg.packages.rio.enable {
    # the nixos rio package doesn't work on darwin and the home manager config file is generated in ~/Library rather than ~/.config
    programs.rio = {
      enable = !pkgs.stdenv.hostPlatform.isDarwin;
    };

    xdg.configFile."rio/config.toml".text = ''
      theme = 'gruvbox'
      [window]
      width = 1200
      height = 800
    '';

    xdg.configFile."rio/themes/gruvbox.toml".text = ''
      [colors]
      # Regular colors
      background = '#282828'
      black = '#282828'
      blue = '#458588'
      cursor = '#bdae93'
      cyan = '#689d6a'
      foreground  = '#ebdbb2'
      green = '#98971a'
      magenta = '#b16286'
      red = '#cc241d'
      white = '#a89984'
      yellow = '#d79921'
      
      # UI colors
      tabs = '#1d2021'
      tabs-active = '#f9f5d7'
      selection-foreground = '#ebdbb2'
      selection-background = '#d65d0e'
      
      # Dim colors
      dim-black = '#928374'
      dim-blue = '#83a598'
      dim-cyan = '#8ec07c'
      dim-foreground = '#d5c4a1'
      dim-green = '#b8bb26'
      dim-magenta = '#d3869b'
      dim-red = '#fb4934'
      dim-white = '#ebdbb2'
      dim-yellow = '#fabd2f'
      
      # Light colors
      light-black = '#32302f'
      light-blue = '#076678'
      light-cyan = '#427b58'
      light-foreground = '#fbf1c7'
      light-green = '#79740e'
      light-magenta = '#8f3f71'
      light-red = '#9d0006'
      light-white = '#fbf1c7'
      light-yellow = '#b57614'
    '';
  };
}
