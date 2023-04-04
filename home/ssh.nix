# I think my GPG/SSH setup needs improving, I don't think it'll work in GUI applications on Mac OS as I no longer have the LaunchAgents that I initially found in yubikey-guide
{ ... }: {
  home.file.".ssh/authorized_keys".source = ../keys/ssh_yubikey.pub;
  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      identitiesOnly = true;
      identityFile = "${../keys/ssh_yubikey.pub}";
      extraOptions = {
        IgnoreUnknown = "UseKeychain";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
    };
  };
}
