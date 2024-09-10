{ config, lib, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles.toyvo.enable = lib.mkEnableOption "Enable toyvo profile";

  config = lib.mkIf cfg.toyvo.enable {
    home.sessionVariables.EDITOR = "nvim";
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
        signing.key = config.sops.secrets."git_toyvo_sign_ed25519.pub".path;
      };
      gpg = {
        enable = true;
        publicKeys = [
          {
            source = ../../../secrets/gpg_yubikey.pub;
            trust = 5;
          }
        ];
      };
      helix.enable = true;
      hyper.enable = cfg.gui.enable;
      ssh =
        let
          identityConfig = {
            identitiesOnly = true;
            identityFile = [
              config.sops.secrets.nixremote_ed25519.path
              config.sops.secrets.ykC_ed25519_sk.path
              config.sops.secrets.ykA_ed25519_sk.path
            ];
          };
        in
        {
          enable = true;
          matchBlocks."github.com" = {
            identitiesOnly = true;
            identityFile = [
              config.sops.secrets.github_toyvo_auth_ed25519.path
              config.sops.secrets.ykC_ed25519_sk.path
              config.sops.secrets.ykA_ed25519_sk.path
            ];
          };
          matchBlocks."oracle" = identityConfig // {
            user = "toyvo";
            hostname = "164.152.23.35";
          };
          matchBlocks."router" = identityConfig // {
            user = "toyvo";
            hostname = "10.1.0.1";
          };
          matchBlocks."nas" = identityConfig // {
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
      "git_toyvo_sign_ed25519.pub".mode = "0644";
      git_toyvo_sign_ed25519.mode = "0600";
      "github_toyvo_auth_ed25519.pub".mode = "0644";
      github_toyvo_auth_ed25519.mode = "0600";
      "nixremote_ed25519.pub".mode = "0644";
      nixremote_ed25519.mode = "0600";
      "ykA_ed25519_sk.pub".mode = "0644";
      ykA_ed25519_sk.mode = "0600";
      "ykC_ed25519_sk.pub".mode = "0644";
      ykC_ed25519_sk.mode = "0600";
    };
  };
}
