{ config, lib, pkgs, self, ... }:
let
  cfg = config.profiles;
  gtk_2_3_attrs = {
    gtk-button-images = true;
    gtk-menu-images = true;
    gtk-toolbar-style = 3;
  };
  gtk_2_3_4_attrs = {
    gtk-enable-animations = true;
    gtk-primary-button-warps-slider = true;
    gtk-sound-theme-name = "ocean";
  };
  gtk_3_4_attrs = {
    gtk-application-prefer-dark-theme = true;
    gtk-decoration-layout = lib.mkIf config.gtk.macbuttons.enable "close,minimize,maximize:icon";
    gtk-modules = "colorreload-gtk-module";
    gtk-xft-dpi = 98304;
  };
in
{
  options.gtk.catppuccin.link = lib.mkEnableOption "Link to local files";
  options.gtk.macbuttons.enable = lib.mkEnableOption "Mac style window decoration buttons with close on the left";

  config = lib.mkIf (cfg.defaults.enable && cfg.gui.enable && pkgs.stdenv.isLinux) {
    xdg.enable = true;
    gtk = {
      enable = true;
      font = {
        name = "Noto Sans";
        size = 10;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = config.catppuccin.flavor;
          accent = config.catppuccin.accent;
        };
      };
      cursorTheme.size = 24;
      gtk2.extraConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} = ${if lib.isString value then "\"${value}\"" else toString value}") (gtk_2_3_attrs // gtk_2_3_4_attrs));
      gtk3.extraConfig = gtk_2_3_attrs // gtk_2_3_4_attrs // gtk_3_4_attrs;
      gtk4.extraConfig = gtk_2_3_4_attrs // gtk_3_4_attrs;
      catppuccin = {
        enable = true;
        flavor = config.catppuccin.flavor;
        accent = config.catppuccin.accent;
        cursor = {
          enable = true;
          flavor = config.catppuccin.flavor;
          accent = config.catppuccin.accent;
        };
      };
    };
    home.file = self.lib.getFiles { dirPath = config.gtk.theme.package; enableLink = config.gtk.catppuccin.link; }
      # // self.lib.getFiles { dirPath = config.gtk.iconTheme.package; enableLink = config.gtk.catppuccin.link; }
      // self.lib.getFiles { dirPath = config.gtk.cursorTheme.package; enableLink = config.gtk.catppuccin.link; };
  };
}

