{ lib, config, ... }:
let
  cfg = config.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      envFile.text = ''
        $env.config = {
          show_banner: false
          edit_mode: vi
        }
        $env.PATH = [
          $'($env.HOME)/.local/bin'
          $'($env.HOME)/.nix-profile/bin'
          $'/etc/profiles/per-user/($env.USER)/bin'
          /run/current-system/sw/bin
          /nix/var/nix/profiles/default/bin
          /usr/local/bin
          /usr/bin
          /bin
          /usr/sbin
          /sbin
        ]
      '';
    };
  };
}

