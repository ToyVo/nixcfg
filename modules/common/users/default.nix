{ lib, ... }:
{
  imports = [ ./toyvo.nix ./chloe.nix ./nixremote.nix ./root.nix ];
  config.home-manager.sharedModules = [{
    profiles.defaults.enable = lib.mkDefault true;
  }];
}
