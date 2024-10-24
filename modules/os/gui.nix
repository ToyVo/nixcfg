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
      (nerdfonts.override {
        fonts = [
          "Monaspace"
          "NerdFontsSymbolsOnly"
        ];
      })
    ];
    environment = {
      systemPackages =
        with pkgs;
        [
          gimp
          inkscape
        ]
        ++ lib.optionals stdenv.isLinux [
          element-desktop
          firefox-bin
          yubikey-manager-qt
          yubioath-flutter
        ]
        ++ lib.optionals (stdenv.system == "x86_64-linux") [
          proton-pass
          protonvpn-gui
        ]
        ++
          lib.optionals
            (builtins.elem system [
              "aarch64-darwin"
              "x86_64-darwin"
              "x86_64-linux"
            ])
            [
              logseq
              protonmail-desktop
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
