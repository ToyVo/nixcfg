{ lib, config, pkgs, ... }:
let
  cfg = config.programs.bash;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash = {
      initExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        if [ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; fi
      '';
    };
  };
}
