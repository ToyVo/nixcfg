{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.gpg.enable = lib.mkEnableOption "Enable gpg";

  config = lib.mkIf cfg.packages.gpg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [{
        source = ../../../../secrets/gpg_yubikey.pub;
        trust = 5;
      }];
    };
    programs.zsh.initExtra = ''
      ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    '';
    services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      enableZshIntegration = true;
      pinentryFlavor = "gnome3";
    };
    home.file = lib.mkIf pkgs.stdenv.isDarwin {
      ".gnupg/gpg-agent.conf".text = ''
        ttyname $GPG_TTY
        default-cache-ttl 60
        max-cache-ttl 120
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
    };
    home.shellAliases = {
      gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
    };
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
    };
    programs.nushell.envFile.text = ''
      $env.GPG_TTY = (echo (tty))
    '';
  };
}
