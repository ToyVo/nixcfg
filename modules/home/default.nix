{ pkgs, lib, config, ... }: let
  symlinkTargetType = path:
    let
      resultFile = pkgs.runCommand "check-symlink-target-type" { } ''
        check_target() {
          if [ -d "$1" ]; then
            echo "directory" > $out
          elif [ -f "$1" ]; then
            echo "file" > $out
          else
            echo "should-not-appear" > $out
          fi
        }

        if [ -L "${path}" ]; then
          check_target $(readlink "${path}")
        else
          check_target "${path}"
        fi
      '';
    in
    builtins.readFile resultFile;
  isDirectory = path: (symlinkTargetType path) == "directory";
  isFile = path: (symlinkTargetType path) == "file";
  listFilesRecursively = dirPath:
    let
      contents = builtins.readDir dirPath;
      # through using builtins.readDir, value is "directory", "regular" or "symlink" for each item
      # I'm having issues with running this with pkgs.catppuccin-papirus-folders which I notice has a bunch of symlinks
      # I'm getting errors with nix about potentially infinite recursion, that is with value != "directory"
      # I think I tried value == "regular" and it didn't work, and that would end up missing some files unless I could follow the symlink?
      files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value == "regular" || (value == "symlink" && isFile name)) contents);
      subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory" || (value == "symlink" && isDirectory name)) contents);
      subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
    in
    files ++ subFiles;

  getFiles = dirPath: builtins.listToAttrs (map
    (name:
      let
        fileFromLocal = ".local/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
      in
      { name = fileFromLocal; value = { source = name; }; })
    (listFilesRecursively dirPath));
 in{
  imports = [ ./alias-home-apps.nix ./users ./programs ];

  options.home = {
    symlinkPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.buildEnv { name = "home-symlink-packages"; paths = config.home.symlinkPackages; };
      description = "Package to be symlinked into the user's .local directory";
      internal = true;
    };
    symlinkPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages to be symlinked into the user's .local directory";
    };
  };

  config = {
    home.file = getFiles config.home.symlinkPackage;
  };
}
