{ pkgs, ... }: {
  imports = [ ./gpg-common.nix ];
  home.file.".gnupg/gpg-agent.conf".text = ''
   enable-ssh-support
   ttyname $GPG_TTY
   default-cache-ttl 60
   max-cache-ttl 120
   pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
}
