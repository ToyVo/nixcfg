{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.gpg.enable = lib.mkEnableOption "Enable gpg" // {
    default = true;
  };

  config = lib.mkIf cfg.gpg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [{
        source = ./gpg_yubikey.pub;
        trust = 5;
      }];
    };
    programs.zsh.initExtra = ''
      gpgconf --launch gpg-agent
    '';
    programs.zsh.profileExtra = ''
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    '';
    services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentryFlavor = "gnome3";
    };
    home.file = lib.mkIf pkgs.stdenv.isDarwin {
      ".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
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
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
    };
  };
}
