{
  pkgs ? import <nixpkgs> { },
  self ? toString ./.,
}:

let
  lib = pkgs.lib;
  flake = builtins.getFlake self;
  ourLib = import "${self}/lib/default.nix" {
    inherit lib;
    inputs = flake.inputs;
  };
  lib' = pkgs.lib.recursiveUpdate lib ourLib;
  pkgs' = lib.recursiveUpdate pkgs { lib = lib'; };
  inputs = flake.inputs;

in
lib.recursiveUpdate (lib'.callDirPackageWithRecursive pkgs' "${self}/pkgs" { inherit inputs; }) {
  lib = ourLib;
  # overlays = lib'.importDirRecursive "${self}/overlays";
  modules = lib'.importDirRecursive "${self}/modules";
}
