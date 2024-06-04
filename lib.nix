{ nixos-unstable, rust-overlay, ... }: with nixos-unstable.lib;
let
  import_nixpkgs = { system, nixpkgs ? nixos-unstable }: import nixpkgs {
    inherit system;
    overlays = [ (import rust-overlay) ];
    config.allowUnfree = true;
  };

  forEachSystems = function:
    genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ]
      (system:
        function (import_nixpkgs {
          inherit system;
        }));


  systemLib = { runCommand, ... }: rec {
    symlinkTargetType = path: builtins.readFile (runCommand "check-symlink-target-type-${builtins.replaceStrings ["/"] ["-"] path}" { } ''
      check_target() {
        if [ -d "$1" ]; then
          printf "%s" "directory" > $out
        elif [ -f "$1" ]; then
          printf "%s" "regular" > $out
        else
          printf "%s" "unknown" > $out
        fi
      }

      if [ -L "${path}" ]; then
        check_target $(readlink "${path}")
      else
        check_target "${path}"
      fi
    '');
    # The possible values for the file type are "regular", "directory", "symlink" and "unknown".
    readDir = dirPath: concatMapAttrs
      (name: value:
        let
          type = if value == "symlink" then symlinkTargetType "${dirPath}/${name}" else value;
        in
        { "${name}" = "${type}"; })
      (builtins.readDir dirPath);
    listFilesRecursively = dirPath:
      let
        contents = readDir dirPath;
        files = mapAttrsToList (name: value: "${dirPath}/${name}") (filterAttrs (name: value: value == "regular") contents);
        subDirectories = mapAttrsToList (name: value: name) (filterAttrs (name: value: value == "directory") contents);
        subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
      in
      files ++ subFiles;

    getFiles = dirPath: builtins.listToAttrs (map
      (name:
        let
          fileFromLocal = ".local/${builtins.unsafeDiscardStringContext (strings.removePrefix "${dirPath}/" name)}";
        in
        { name = fileFromLocal; value = { source = name; }; })
      (listFilesRecursively dirPath));
  };
in
{
  inherit forEachSystems import_nixpkgs;
} // forEachSystems systemLib
