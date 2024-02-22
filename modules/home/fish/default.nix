{ lib, config, pkgs, ... }:
let
  cfg = config.programs.fish;
in
{
  config = lib.mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = ''
        set fish_greeting
        if test -e $HOME/.nix-profile/etc/profile.d/nix.fish
          source $HOME/.nix-profile/etc/profile.d/nix.fish
        end
        if test -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
          ${pkgs.babelfish}/bin/babelfish < $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh | source
        end
      '';
    };
  };
}

