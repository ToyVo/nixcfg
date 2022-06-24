# I think my GPG/SSH setup needs improving, I don't think it'll work in GUI applications on Mac OS as I no longer have the LaunchAgents that I initially found in yubikey-guide
{pkgs, ...}: {
  # TODO: this is only needed on macos where services.gpg-agent is unavailable
  home.file.".gnupg/gpg-agent.conf".text = ''
    enable-ssh-support
    ttyname $GPG_TTY
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  programs.gpg = {
    enable = true;
    publicKeys = [
      { source = ./gpg_yubikey.pub; trust = 5; }
    ];
  };
}
