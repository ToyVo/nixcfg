{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.ssh.enable = lib.mkEnableOption "Enable ssh";

  config = lib.mkIf cfg.packages.ssh.enable {
    programs = {
      ssh = {
        enable = true;
        matchBlocks."10.1.0.*" = {
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/ykC_ed25519_sk"
            "~/.ssh/ykA_ed25519_sk"
          ];
          extraOptions.AddKeysToAgent = "yes";
        };
        matchBlocks."github.com" = {
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/ykC_ed25519_sk"
            "~/.ssh/ykA_ed25519_sk"
          ];
          extraOptions.AddKeysToAgent = "yes";
        };
      };
      zsh.initExtra = ''
        eval $(ssh-agent -s)
      '';
      bash.initExtra = ''
        eval $(ssh-agent -s)
      '';
      fish.interactiveShellInit = ''
        eval $(ssh-agent -c)
      '';
    };
  };
}
