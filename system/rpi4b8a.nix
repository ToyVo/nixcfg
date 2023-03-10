{ config, pkgs, lib, ... }: {
  imports = [
    ./common.nix
    ./nixos.nix
  ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking.hostName = "rpi4b8a";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware.raspberry-pi."4".fkms-3d.enable = true;
}
