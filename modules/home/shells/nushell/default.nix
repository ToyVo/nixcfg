{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.nushell.enable = lib.mkEnableOption "Enable nushell";

  config = lib.mkIf cfg.packages.nushell.enable {
    programs.nushell = {
      enable = true;
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

