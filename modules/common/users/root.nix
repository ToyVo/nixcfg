{ config, lib, pkgs, ... }:
let
  rootHomeDirectory =
    if pkgs.stdenv.isDarwin then
      "/var/root" else
      "/root";
in
{
  users.users.root = {
    name = "root";
    home = rootHomeDirectory;
  };
  nix.settings.trusted-users = [ "root" ];
  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = rootHomeDirectory;
    programs.ssh = lib.mkIf config.services.remote-builds.client.enable {
      enable = lib.mkDefault true;
      matchBlocks."builder" = {
        user = "nixremote";
        hostname = "10.1.0.3";
        identitiesOnly = true;
        # TODO: automatically put the key in the right place without pulling it into the store
        identityFile = "${rootHomeDirectory}/.ssh/nixremote_ed25519";
      };
    };
  };
}
