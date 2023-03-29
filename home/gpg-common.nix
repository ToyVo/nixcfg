{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    publicKeys = [
      { source = ../keys/gpg_yubikey.pub; trust = 5; }
    ];
  };
}
