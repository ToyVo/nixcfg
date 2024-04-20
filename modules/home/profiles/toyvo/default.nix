{ pkgs, lib, config, ... }:
let 
  cfg = config.profiles;
in 
{
  options.profiles = {
    toyvo.enable = lib.mkEnableOption "Enable toyvo profile";
  };

  config = lib.mkIf cfg.toyvo.enable {
    profiles.defaults.enable = lib.mkDefault true;
    # TODO: Build a rebuild script that does a few things:
    # 1. pull the git repo (I store it at ~/nixcfg)
    # - `git -C ~/nixcfg pull`
    # 2. check for any conflicts
    # 3. rebuild the system which depends on the system
    # - if nixos-rebuild and darwin-rebuild don't exist, assume that we can use home-manager
    home = {
      sessionVariables.EDITOR = "nvim";
    };
    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      rio.enable = cfg.gui.enable;
      vscode.enable = cfg.gui.enable;
      wezterm.enable = cfg.gui.enable;
      kitty.enable = cfg.gui.enable;
      git.enable = true;
      gpg.enable = true;
      helix.enable = true;
      ssh.enable = true;
      zellij.enable = true;
      ideavim.enable = true;
    };
  };
}


