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
  listFilesRecursively = runCommand: dirPath:
    let
      contents = builtins.readDir dirPath;
      # through using builtins.readDir, value is "directory", "regular" or "symlink" for each item
      # I'm having issues with running this with pkgs.catppuccin-papirus-folders which I notice has a bunch of symlinks
      # I'm getting errors with nix about potentially infinite recursion, that is with value != "directory"
      # I think I tried value == "regular" and it didn't work, and that would end up missing some files unless I could follow the symlink?
      files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: (symlinkTargetType runCommand name) != "file\n") contents);
      subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: (symlinkTargetType runCommand name) != "directory\n") contents);
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
  inherit getFiles symlinkTargetType listFilesRecursively;
}
