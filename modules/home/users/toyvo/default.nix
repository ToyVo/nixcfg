{ config, lib, ... }:
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
    gtk.macbuttons.enable = true;
    programs = {
      alacritty.enable = cfg.gui.enable;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      rio.enable = cfg.gui.enable;
      vscode.enable = cfg.gui.enable;
      wezterm.enable = cfg.gui.enable;
      kitty.enable = cfg.gui.enable;
      git = {
        enable = true;
        signing.signByDefault = true;
        userName = "Collin Diekvoss";
        userEmail = "Collin@Diekvoss.com";
        signing.key = "D18E177DD717DD88!";
      };
      gpg = {
        enable = true;
        publicKeys = [{
          source = ./gpg_yubikey.pub;
          trust = 5;
        }];
      };
      helix.enable = true;
      hyper.enable = cfg.gui.enable;
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
          enable = true;
          matchBlocks."10.1.0.*" = identityConfig;
          matchBlocks."github.com" = identityConfig;
        };
      zellij.enable = true;
      ideavim.enable = true;
    };
    catppuccin = {
      flavor = "frappe";
      accent = "red";
    };
  };
}


