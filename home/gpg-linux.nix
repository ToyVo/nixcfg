{...}: {
  imports = [ ./gpg-common.nix ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentryFlavor = "gnome3";
  };
}
