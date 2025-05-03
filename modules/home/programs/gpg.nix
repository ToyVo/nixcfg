{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.gpg;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh.initContent = ''
      ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    '';
    services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      enableZshIntegration = true;
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
      gpg-scan-card = "gpg-connect-agent \"scd serialno\" \"learn --force\" /bye";
    };
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
    };
    programs.nushell.extraEnv = ''
      $env.GPG_TTY = (echo (tty))
    '';
  };
}
