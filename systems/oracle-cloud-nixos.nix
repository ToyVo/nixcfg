{ lib, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
  networking.hostName = "oracle-cloud-nixos";
  profiles.defaults.enable = true;
  services.openssh.enable = true;
  userPresets.toyvo.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    (lib.fileContents ../modules/common/users/nixremote_ed25519.pub)
  ];
  container-presets.minecraft = {
    enable = true;
    openFirewall = true;
    datadir = "/minecraft-data";
  };
  disko.devices.disk.sda = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          name = "ESP";
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            extraArgs = [ "-n" "BOOT" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-L" "NIXOS" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "@nix" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
