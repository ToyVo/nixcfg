{ lib, config, ... }:
let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      ssh =
        let
          identityConfig = {
            identitiesOnly = true;
            identityFile = [
              "~/.ssh/ykC_ed25519_sk"
              "~/.ssh/ykA_ed25519_sk"
            ];
          };
        in
        {
          matchBlocks."10.1.0.*" = identityConfig;
          matchBlocks."github.com" = identityConfig;
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
