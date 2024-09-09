{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  options.profiles.gui.enable = lib.mkEnableOption "GUI Applications";

  config = lib.mkIf cfg.gui.enable {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-monochrome-emoji
      monaspace
      (nerdfonts.override { fonts = [ "Monaspace" "NerdFontsSymbolsOnly" ]; })
    ];
    environment = {
      systemPackages = with pkgs; [
        gimp
      ]
      ++ lib.optionals stdenv.isLinux [
        element-desktop
        firefox-devedition-bin
        yubikey-manager-qt
        yubioath-flutter
      ]
      ++ lib.optionals stdenv.isDarwin [
        appcleaner
        pinentry_mac
        rectangle
        utm
        warp-terminal
      ];
    };
  };
}
