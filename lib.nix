{ nixos-unstable, ... }:
let
  lib = nixos-unstable.lib;
  symlinkTargetType = runCommand: path:
    let
      resultFile = runCommand "check-symlink-target-type" { } ''
        check_target() {
          if [ -d "$1" ]; then
            printf "%s" "directory" > $out
          elif [ -f "$1" ]; then
            printf "%s" "regular" > $out
          else
            printf "%s" "should-not-appear" > $out
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
  # through using builtins.readDir, value is "directory", "regular" or "symlink" for each item
  readDir = runCommand: dirPath: lib.concatMapAttrs
    (name: value:
      let
        type = if value == "symlink" then symlinkTargetType runCommand "${dirPath}/${name}" else value;
      in
      { "${name}" = "${type}"; })
    builtins.readDir
    dirPath;
  listFilesRecursively = runCommand: dirPath:
    let
      contents = builtins.readDir dirPath;
      files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: (symlinkTargetType runCommand "${dirPath}/${name}") != "regular") contents);
      subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: (symlinkTargetType runCommand "${dirPath}/${name}") != "directory") contents);
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
  inherit getFiles symlinkTargetType listFilesRecursively readDir;
}
