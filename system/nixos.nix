{ config, pkgs, ... }:
{
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
  users.users.toyvo = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$jbvaDiuNpoRm.blRGD/Ne1$OpPEzRKM1u5/9On95bVlxS6r1N88c/MAoS479r1GRj5";
    description = "Collin Diekvoss";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../home/assets/ssh_yubikey.pub ];
    shell = pkgs.zsh;
  };
  environment.systemPackages = with pkgs; [
    yubikey-personalization
  ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  system.stateVersion = "22.11";
}
