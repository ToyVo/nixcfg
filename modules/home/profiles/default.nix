{ pkgs, lib, config, ... }:
let 
  cfg = config.profiles;
in 
{
  options.profiles = {
    defaults.enable = lib.mkEnableOption "Enable toyvo profile";
    gui.enable = lib.mkEnableOption "Enable GUI applications";
  };

  config = lib.mkIf cfg.defaults.enable {
    home = {
      stateVersion = "24.05";
      sessionPath = [ "$HOME/.local/bin" ];
    };
    xdg.configFile = {
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
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
      zsh.enable = true;
      bash.enable = true;
      fish.enable = true;
      nushell.enable = true;
      powershell.enable = true;
    };
    services.easyeffects = lib.mkIf (pkgs.stdenv.isLinux && cfg.gui.enable) {
      enable = true;
    };
  };
}

