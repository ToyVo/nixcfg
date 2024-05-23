{ lib, ... }:
let
  listFilesRecursively = dirPath:
    let
      contents = builtins.readDir dirPath;
      # through using builtins.readDir, value is "directory", "regular" or "symlink" for each item
      # I'm having issues with running this with pkgs.catppuccin-papirus-folders which I notice has a bunch of symlinks
      # I'm getting errors with nix about potentially infinite recursion, that is with value != "directory"
      # I think I tried value == "regular" and it didn't work, and that would end up missing some files unless I could follow the symlink?
      files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value != "directory") contents);
      subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory") contents);
      subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
    in
    files ++ subFiles;

  getFiles = dirPath: enableLink: pathToLink: builtins.listToAttrs (map
    (name:
      let
        fileFromLocal = "${pathToLink}/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
      in
      { name = fileFromLocal; value = { source = name; enable = enableLink; }; })
    (listFilesRecursively dirPath));
in
{
  getFiles = { dirPath, enableLink ? true, pathToLink ? ".local" }: getFiles dirPath enableLink pathToLink;
}
