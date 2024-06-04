{ nixos-unstable, ... }:
let
  lib = nixos-unstable.lib;
  symlinkTargetType = runCommand: path:
    let
      resultFile = runCommand "check-symlink-target-type" { } ''
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
  isDirectory = runCommand: path: (symlinkTargetType runCommand path) == "directory\n";
  isFile = runCommand: path: (symlinkTargetType runCommand path) == "file\n";
  listFilesRecursively = runCommand: dirPath:
    let
      contents = builtins.readDir dirPath;
      # through using builtins.readDir, value is "directory", "regular" or "symlink" for each item
      # I'm having issues with running this with pkgs.catppuccin-papirus-folders which I notice has a bunch of symlinks
      # I'm getting errors with nix about potentially infinite recursion, that is with value != "directory"
      # I think I tried value == "regular" and it didn't work, and that would end up missing some files unless I could follow the symlink?
      files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value == "regular" || (value == "symlink" && isFile runCommand name)) contents);
      subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory" || (value == "symlink" && isDirectory runCommand name)) contents);
      subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively runCommand "${dirPath}/${subDir}") subDirectories);
    in
    files ++ subFiles;

  getFiles = runCommand: dirPath: builtins.listToAttrs (map
    (name:
      let
        fileFromLocal = ".local/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
      in
      { name = fileFromLocal; value = { source = name; }; })
    (listFilesRecursively runCommand dirPath));
in
{
  inherit isFile isDirectory getFiles symlinkTargetType listFilesRecursively;
}
