{ pkgs, config, lib, ... }:
{
  imports = [ ../../secrets/secrets.nix ];

  config = {
    sops.secrets = {
      ykW_ed25519_sk.mode = "0600";
      "ykW_ed25519_sk.pub".mode = "0644";
      emu_ed25519.mode = "0600";
      "emu_ed25519.pub".mode = "0644";
    };
    programs = {
      ssh.matchBlocks."github-emu" = {
        hostname = "github.com";
        identitiesOnly = true;
        identityFile = config.sops.secrets.emu_ed25519.path;
      };
      gpg.publicKeys = [{
        source = ../../secrets/gpg_emu.pub;
        trust = 5;
      }];
      volta = {
        enable = true;
        package = pkgs.emptyDirectory;
      };
    };
  };
}
