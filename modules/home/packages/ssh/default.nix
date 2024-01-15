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
        };
        matchBlocks."github.com" = {
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/ykC_ed25519_sk"
            "~/.ssh/ykA_ed25519_sk"
          ];
        };
      };
      zsh.initExtra = ''
        ! (echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      bash.initExtra = ''
        ! (echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+$) >/dev/null && eval $(ssh-agent -s) >/dev/null
      '';
      fish.interactiveShellInit = ''
        ! echo "$SSH_AUTH_SOCK" | rg ssh-\[a-zA-Z0-9\]+\/agent\.\\d+\$ >/dev/null; and eval $(ssh-agent -c) >/dev/null
      '';
      nushell.configFile.text = ''
        if (echo $env.SSH_AUTH_SOCK | rg ssh-[a-zA-Z0-9]+/agent\.\d+$) == "" {
          ^ssh-agent -c
              | lines
              | first 2
              | parse "setenv {name} {value};"
              | transpose -r
              | into record
              | load-env
        }
      '';
    };
  };
}
