# I think my GPG/SSH setup needs improving, I don't think it'll work in GUI applications on Mac OS as I no longer have the LaunchAgents that I initially found in yubikey-guide
{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      identitiesOnly = true;
      identityFile = "${./ssh_yubikey.pub}";
      extraOptions = {
        IgnoreUnknown = "UseKeychain";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
    };
  };
}
