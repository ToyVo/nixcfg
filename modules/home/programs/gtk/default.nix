{ pkgs, lib, config, ... }:
let 
  cfg = config.profiles;
  gtk_2_3_4_attrs = {
    gtk-enable-animations = true;
    gtk-primary-button-warps-slider = true;
    gtk-sound-theme-name = "ocean";
  };
  gtk_2_3_attrs = {
    gtk-button-images = true;
    gtk-menu-images = true;
    gtk-toolbar-style = 3;
  };
  gtk_3_4_attrs = {
    gtk-application-prefer-dark-theme = true;
    gtk-decoration-layout = "close,minimize,maximize:icon";
    gtk-modules = "colorreload-gtk-module";
    gtk-xft-dpi = 98304;
  };
in 
{
  config = lib.mkIf (cfg.defaults.enable && cfg.gui.enable && pkgs.stdenv.isLinux) {
    gtk = {
      enable = true;
      font = {
        name = "MonaspiceNe Nerd Font";
        size = 10;
      };
      iconTheme.name = "Papirus-Dark";
      cursorTheme.size = 24;
      gtk2.extraConfig = let 
        toGtk2 = value: if lib.isBool value then if value then "1" else "0" else if lib.isString value then "\"${value}\"" else lib.toString value;
      in ''
        ${lib.mapAttrsToList (name: value: "${name}=${toGtk2 value}") gtk_2_3_attrs}
        ${lib.mapAttrsToList (name: value: "${name}=${toGtk2 value}") gtk_2_3_4_attrs}
      '';
      gtk3.extraConfig = ''
        ${lib.mapAttrsToList (name: value: "${name}=${value}") gtk_2_3_attrs}
        ${lib.mapAttrsToList (name: value: "${name}=${value}") gtk_3_4_attrs}
      '';
      gtk4.extraConfig = ''
        ${lib.mapAttrsToList (name: value: "${name}=${value}") gtk_2_3_attrs}
        ${lib.mapAttrsToList (name: value: "${name}=${value}") gtk_3_4_attrs}
      '';
      catppuccin = {
        enable = true;
        flavour = config.catppuccin.flavour;
        accent = config.catppuccin.accent;
        cursor = {
          enable = true;
          flavour = config.catppuccin.flavour;
          accent = config.catppuccin.accent;
        };
      };
    };
  };
}

