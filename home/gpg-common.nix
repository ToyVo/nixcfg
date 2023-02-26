{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    publicKeys = [
      { source = ./assets/gpg_yubikey.pub; trust = 5; }
    ];
  };
}
