{ pkgs, ... }:
{
  imports = [ ./secrets.nix ];

  programs = {
    ssh.matchBlocks."github-emu" = {
      hostname = "github.com";
      identitiesOnly = true;
      identityFile = "~/.ssh/emu_ed25519";
    };
    gpg.publicKeys = [{
      source = ./gpg_emu.pub;
      trust = 5;
    }];
    volta = {
      enable = true;
      package = pkgs.emptyDirectory;
    };
  };
}
