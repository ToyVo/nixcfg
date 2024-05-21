{ lib, config, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles = {
    toyvo.enable = lib.mkEnableOption "Enable toyvo profile";
  };

  config = lib.mkIf cfg.toyvo.enable {
    profiles.defaults.enable = lib.mkDefault true;
    home.sessionVariables.EDITOR = "nvim";
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
    catppuccin = {
      flavour = "frappe";
      accent = "red";
    };
  };
}


