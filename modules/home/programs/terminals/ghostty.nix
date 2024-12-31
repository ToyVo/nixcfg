{pkgs, lib, ...}: {
  home.packages = with pkgs; lib.mkIf stdenv.isLinux [
    ghostty
  ];
  xdg.configFile."ghostty/config".text = ''
    background-opacity = 0.8
    font-family = MonaspiceAr Nerd Font Mono
    font-feature = calt
    font-feature = ss01
    font-feature = ss02
    font-feature = ss03
    font-feature = ss04
    font-feature = ss05
    font-feature = ss06
    font-feature = ss07
    font-feature = ss08
    font-feature = ss09
    font-feature = liga
    theme = catppuccin-frappe
    command = ${lib.getExe pkgs.fish}
  '';
}
