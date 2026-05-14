{
  pkgs ? import <nixpkgs> { },
  self ? toString ./.,
}:

let
  lib = pkgs.lib;
  ourLib = import "${self}/lib/default.nix" { inherit lib; };
  lib' = pkgs.lib.recursiveUpdate lib ourLib;
  pkgs' = lib.recursiveUpdate pkgs { lib = lib'; };
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  inputs = {
    nvf = import (lib.fetchFromGithub {
      inherit (lock.nodes.nvf.locked) owner repo rev;
      sha256 = lock.nodes.nvf.locked.harHash;
    }) { };
  };

in
lib.recursiveUpdate (lib'.callDirPackageWithRecursive pkgs' "${self}/pkgs" { inherit inputs; }) {
  lib = ourLib;
  # overlays = lib'.importDirRecursive "${self}/overlays";
  modules = lib'.importDirRecursive "${self}/modules";
}
