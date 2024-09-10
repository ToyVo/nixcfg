{ pkgs, config, ... }:
{
  imports = [ ../../secrets/secrets.nix ];

  config = {
    sops.secrets = {
      ykW_ed25519_sk.mode = "0600";
      "ykW_ed25519_sk.pub".mode = "0644";
      git_work_sign_ed25519.mode = "0600";
      "git_work_sign_ed25519.pub".mode = "0644";
      github_work_auth_ed25519.mode = "0600";
      "github_work_auth_ed25519.pub".mode = "0644";
    };
    programs = {
      ssh.matchBlocks = {
        "github-emu" = {
          hostname = "github.com";
          identitiesOnly = true;
          identityFile = config.sops.secrets.github_work_auth_ed25519.path;
        };
      };
      gpg.publicKeys = [
        {
          source = ../../secrets/gpg_work.pub;
          trust = 5;
        }
      ];
      volta = {
        enable = true;
        package = pkgs.emptyDirectory;
      };
    };
  };
}
