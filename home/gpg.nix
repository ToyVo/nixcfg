{ pkgs, lib, ... }:
lib.mkMerge [
  {
    programs.gpg = {
      enable = true;
      publicKeys = [
        { source = ../keys/gpg_yubikey.pub; trust = 5; }
      ];
    };
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentryFlavor = "gnome3";
    };
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      ttyname $GPG_TTY
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  })
]
