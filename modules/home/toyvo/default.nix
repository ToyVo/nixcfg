{ pkgs, lib, config, ... }:
let 
  enableGui = config.profiles.gui.enable;
in 
{
  options.profiles = {
    toyvo.enable = lib.mkEnableOption "Enable toyvo profile";
    gui.enable = lib.mkEnableOption "Enable GUI applications";
  };

  config = lib.mkIf config.profiles.toyvo.enable {
    home = {
      stateVersion = "24.05";
      sessionVariables = {
        EDITOR = "nvim";
      };
      sessionPath = [ "$HOME/.local/bin" ];
    };
    xdg.configFile = {
      "ideavim/ideavimrc".source = ./ideavimrc;
      "nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
      "nixpkgs/config.nix".text = ''
        { allowUnfree = true; }
      '';
    };
    programs = {
      home-manager.enable = true;
      starship = {
        enable = true;
        settings = {
          right_format = "$time";
          time.disabled = false;
        };
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      rio.enable = enableGui;
      vscode.enable = enableGui;
      wezterm.enable = enableGui;
      kitty.enable = enableGui;
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
      git.enable = true;
      gpg.enable = true;
      helix.enable = true;
      ssh.enable = true;
      zellij.enable = true;
      zsh.enable = true;
      bash.enable = true;
      fish.enable = true;
      nushell.enable = true;
    };
    services.easyeffects = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };
  };
}

