{ config, lib, pkgs, ... }:
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
      alacritty.enable = cfg.gui.enable;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      # TODO fix when not broken on darwin
      rio.enable = cfg.gui.enable && pkgs.stdenv.isLinux;
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
          source = ../../../secrets/gpg_yubikey.pub;
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
              config.sops.secrets.ykC_ed25519_sk.path
              config.sops.secrets.ykA_ed25519_sk.path
            ];
          };
        in
        {
          enable = true;
          matchBlocks."github.com" = identityConfig;
          matchBlocks."oracle" = identityConfig // {
            user = "toyvo";
            hostname = "164.152.23.35";
          };
          matchBlocks."router" = identityConfig // {
            user = "toyvo";
            hostname = "10.1.0.1";
          };
          matchBlocks."ncase" = identityConfig // {
            user = "toyvo";
            hostname = "10.1.0.3";
          };
          matchBlocks."protectli" = identityConfig // {
            user = "toyvo";
            hostname = "10.1.0.6";
          };
          matchBlocks."10.1.0.*" = identityConfig;
        };
      zed.enable = true;
      zellij.enable = true;
      ideavim.enable = true;
    };
    catppuccin = {
      flavor = "frappe";
      accent = "red";
    };
    sops.secrets = {
      ykC_ed25519_sk.mode = "0600";
      "ykC_ed25519_sk.pub".mode = "0644";
      ykA_ed25519_sk.mode = "0600";
      "ykA_ed25519_sk.pub".mode = "0644";
    };
  };
}
