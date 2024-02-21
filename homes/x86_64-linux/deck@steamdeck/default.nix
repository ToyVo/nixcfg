{ pkgs, ... }:
{
  home.username = "deck";
  home.homeDirectory = "/home/deck";
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
  programs.bash.initExtra = ''
    if [ -e /home/deck/.nix-profile/etc/profile.d/nix.sh ]; then . /home/deck/.nix-profile/etc/profile.d/nix.sh; fi
    if [ -e /home/deck/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then . /home/deck/.nix-profile/etc/profile.d/hm-session-vars.sh; fi
  '';
  profiles.toyvo.enable = true;
  profiles.gui.enable = true;
}
