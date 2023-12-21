{ lib, pkgs, ... }:
{
  home.username = "deck";
  home.homeDirectory = "/home/deck";
  home.stateVersion = "23.11";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = with pkgs; [
    obs-studio-plugins.obs-vkcapture
  ];
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
  programs.zoxide.enable = true;
  imports = [
    {
      options.cd.username = lib.mkOption {
        type = lib.types.str;
        default = "deck";
      };
      config.cd.packages = {
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
    }
  ];
}
