{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coreutils
  ];
  services.nix-daemon.enable = true;
  programs.zsh.enable = true;
  system.stateVersion = 4;
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
