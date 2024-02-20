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
}
