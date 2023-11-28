{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.nushell.enable = lib.mkEnableOption "Enable nushell";

  config = lib.mkIf cfg.packages.nushell.enable {
    programs.nushell = {
      enable = true;
      envFile.text = ''
        $env.PATH = [
          /Users/${cfg.username}/.local/bin
          /Users/${cfg.username}/.nix-profile/bin
          /etc/profiles/per-user/${cfg.username}/bin
          /run/current-system/sw/bin
          /nix/var/nix/profiles/default/bin
          /opt/homebrew/bin
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

