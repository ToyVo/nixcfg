{ config, lib, pkgs, ... }:
let
  rootHomeDirectory =
    if pkgs.stdenv.isDarwin then
      "/var/root" else
      "/root";
in
{
  users.users.root = lib.mkMerge [
    {
      name = "root";
      home = rootHomeDirectory;
      shell = pkgs.zsh;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      hashedPassword = "";
    })
  ];
  nix.settings.trusted-users = [ "root" ];
  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = rootHomeDirectory;
    programs.zsh.enableCompletion = false;
    programs.ssh = lib.mkIf config.services.remote-builds.client.enable {
      enable = lib.mkDefault true;
      matchBlocks."builder" = {
        user = "nixremote";
        hostname = "10.1.0.3";
        identitiesOnly = true;
        identityFile = config.sops.secrets.nixremote_ed25519.path;
      };
    };
    sops.secrets = lib.mkIf config.services.remote-builds.client.enable {
      nixremote_ed25519.mode = "0600";
      "nixremote_ed25519.pub".mode = "0644";
    };
  };
}
