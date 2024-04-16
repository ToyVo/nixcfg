{ pkgs, lib, config, ... }:
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
    gtk-decoration-layout = "close,minimize,maximize:icon";
    gtk-modules = "colorreload-gtk-module";
    gtk-xft-dpi = 98304;
  };
  listFilesRecursively = dirPath: let
    contents = builtins.readDir dirPath;
    files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value != "directory") contents);
    subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory") contents);
    subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
  in
    files ++ subFiles;

  getFiles = dirPath: let in builtins.listToAttrs (map (name: let
    fileFromLocal = ".local/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
  in { name = fileFromLocal; value = {source = name; enable = config.gtk.catppuccin.link; }; }) (listFilesRecursively dirPath));
in 
{
  options.gtk.catppuccin.link = lib.mkEnableOption "Link to local files";

  config = lib.mkIf (cfg.defaults.enable && cfg.gui.enable && pkgs.stdenv.isLinux) {
    gtk = {
      enable = true;
      font = {
        name = "MonaspiceNe Nerd Font";
        size = 10;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = config.catppuccin.flavour;
          accent = config.catppuccin.accent;
        };
      };
      cursorTheme.size = 24;
      gtk2.extraConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} = ${if lib.isString value then "\"${value}\"" else toString value}") (gtk_2_3_attrs // gtk_2_3_4_attrs));
      gtk3.extraConfig = gtk_2_3_attrs // gtk_2_3_4_attrs // gtk_3_4_attrs;
      gtk4.extraConfig = gtk_2_3_4_attrs // gtk_3_4_attrs;
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
    home.file = getFiles config.gtk.theme.package;
  };
}

