{ pkgs, lib, config, ... }: let 
  cfg = config.programs.kde.catppuccin;
  catppuccin-kde = (pkgs.catppuccin-kde.override {
    flavour = [ config.catppuccin.flavour ];
    accents = [ config.catppuccin.accent ];
    winDecStyles = [ "classic" ];
  });
  listFilesRecursively = dirPath: let
    contents = builtins.readDir dirPath;
    files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value != "directory") contents);
    subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory") contents);
    subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
  in
    files ++ subFiles;

  getFiles = dirPath: let in builtins.listToAttrs (map (name: let
    fileFromLocal = ".local/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
  in { name = fileFromLocal; value = {source = name;}; }) (listFilesRecursively dirPath));
in {
  options.programs.kde.catppuccin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.profiles.defaults.enable && config.profiles.gui.enable && pkgs.stdenv.isLinux;
      description = "Enable Catppuccin KDE theme";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      catppuccin-kde
    ];
    home.file = getFiles catppuccin-kde;
  };
}