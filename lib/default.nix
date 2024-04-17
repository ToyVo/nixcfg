{ lib, inputs, ... }: let
  listFilesRecursively = dirPath: let
    contents = builtins.readDir dirPath;
    files = lib.mapAttrsToList (name: value: "${dirPath}/${name}") (lib.filterAttrs (name: value: value != "directory") contents);
    subDirectories = lib.mapAttrsToList (name: value: name) (lib.filterAttrs (name: value: value == "directory") contents);
    subFiles = builtins.concatLists (builtins.map (subDir: listFilesRecursively "${dirPath}/${subDir}") subDirectories);
  in
    files ++ subFiles;

  getFiles = dirPath: enableLink: pathToLink: builtins.listToAttrs (map (name: let
    fileFromLocal = "${pathToLink}/${builtins.unsafeDiscardStringContext (lib.strings.removePrefix "${dirPath}/" name)}";
  in { name = fileFromLocal; value = {source = name; enable = enableLink; }; }) (listFilesRecursively dirPath));
in {
  getFiles = {dirPath, enableLink ? true, pathToLink ? ".local"}: getFiles dirPath enableLink pathToLink;
}