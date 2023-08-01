{ pkgs, ... }: {
  imports = [
    ../common
    ./gnome.nix
    ./xfce.nix
    ./hyprland.nix
    ./gui.nix
    ./plasma.nix
    ./filesystem/boot.nix
    ./filesystem/btrfs.nix
  ];
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  console.useXkbConfig = true;
  services.xserver = {
    layout = "us";
    xkbOptions = "ctrl:nocaps";
  };
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubico-piv-tool
  ];
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  system = {
    stateVersion = "23.05";
    autoUpgrade.enable = true;
    autoUpgrade.flake = "github:toyvo/dotfiles";
    autoUpgrade.persistent = true;
  };
}
