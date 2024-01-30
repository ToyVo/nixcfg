{ pkgs, ... }:
{
  home.username = "deck";
  home.homeDirectory = "/home/deck";
  home.stateVersion = "24.05";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = with pkgs; [
    r2modman
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-gstreamer
        obs-vkcapture
        obs-vaapi
      ];
    })
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
  programs.bash.initExtra = ''
    if [ -e /home/deck/.nix-profile/etc/profile.d/nix.sh ]; then . /home/deck/.nix-profile/etc/profile.d/nix.sh; fi
    if [ -e /home/deck/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . /home/deck/.nix-profile/etc/profile.d/hm-session-vars.sh; fi
  '';
  imports = [
    {
      cd.packages = {
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
