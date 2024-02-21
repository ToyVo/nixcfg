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
    home.stateVersion = "24.05";
    home.sessionVariables = {
      EDITOR = "nvim";
    };
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.packages = with pkgs; [
      lazygit
    ];
    xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
    xdg.configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';
    xdg.configFile."nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
    programs.home-manager.enable = true;
    programs.starship = {
      enable = true;
      settings = {
        right_format = "$time";
        time.disabled = false;
      };
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.rio.enable = enableGui;
    programs.vscode.enable = enableGui;
    programs.wezterm.enable = enableGui;
    programs.kitty.enable = enableGui;
    programs.zoxide.enable = true;
    programs.bat.enable = true;
    programs.eza.enable = true;
    programs.git.enable = true;
    programs.gpg.enable = true;
    programs.helix.enable = true;
    programs.ssh.enable = true;
    programs.zellij.enable = true;
    programs.zsh.enable = true;
    programs.bash.enable = true;
    programs.fish.enable = true;
    programs.nushell.enable = true;
    services.easyeffects.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}

