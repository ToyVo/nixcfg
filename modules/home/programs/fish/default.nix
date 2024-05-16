{ lib, config, pkgs, ... }:
let
  cfg = config.programs.fish;
in
{
  config = lib.mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings
      '';
      shellInit = ''
        if test -e $HOME/.nix-profile/etc/profile.d/nix.fish
          source $HOME/.nix-profile/etc/profile.d/nix.fish
        end
        if test -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
          ${pkgs.babelfish}/bin/babelfish < $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh | source
        end

        set nix_paths ${lib.concatStringsSep " " config.home.sessionPath}
        set paths_to_export
        for path in $PATH
          if test -d $path && not contains $path $nix_paths
            set paths_to_export $paths_to_export $path
          end
        end
        for path in $nix_paths
          if test -d $path
            set paths_to_export $paths_to_export $path
          end
        end
        set -x PATH $paths_to_export
      '';
    };
  };
}

