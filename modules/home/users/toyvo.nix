{
  config,
  lib,
  pkgs,
  ...
}:
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
      # TODO: undo
      rio.enable = cfg.gui.enable && pkgs.stdenv.isLinux;
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
            hostname = "oracle.internal";
          };
          matchBlocks."router" = identityConfig // {
            user = "toyvo";
            hostname = "router.internal";
          };
          matchBlocks."nas" = identityConfig // {
            user = "toyvo";
            hostname = "nas.internal";
          };
          matchBlocks."protectli" = identityConfig // {
            user = "toyvo";
            hostname = "protectli.internal";
          };
          matchBlocks."macmini-m1" = identityConfig // {
            user = "toyvo";
            hostname = "macmini-m1.internal";
          };
          matchBlocks."macmini-intel" = identityConfig // {
            user = "toyvo";
            hostname = "macmini-intel.internal";
          };
          matchBlocks."windows-desktop" = identityConfig // {
            user = "toyvo";
            hostname = "windows-desktop.internal";
          };
          matchBlocks."steamdeck-nixos" = identityConfig // {
            user = "toyvo";
            hostname = "steamdeck-nixos.internal";
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
      cachix_auth_token.mode = "0644";
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
