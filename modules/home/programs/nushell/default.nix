{ lib, config, system, ... }:
let
  cfg = config.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      envFile.text = lib.mkMerge [
        (''
          $env.config = {
            show_banner: false
            edit_mode: vi
          }
          $env.PATH = [
            $'($env.HOME)/.local/bin'
            /run/wrappers/bin
            $'($env.HOME)/.nix-profile/bin'
            /nix/profile/bin
            $'($env.HOME)/.local/state/nix/profile/bin
            $'/etc/profiles/per-user/($env.USER)/bin'
            /nix/var/nix/profiles/default/bin
            /run/current-system/sw/bin'')
        (lib.mkIf (system == "aarch64-darwin") ''
            /opt/homebrew/bin
            /opt/homebrew/sbin'')
        # TODO: should only be set if not nixos
        (''
            /usr/local/bin
            /usr/bin
            /usr/sbin
            /bin
            /sbin
          ]
        '')
      ];
    };
  };
}

