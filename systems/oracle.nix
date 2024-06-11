{ lib, config, pkgs, nixos-unstable, ... }: {
  networking.hostName = "oracle-ampere-nixos";
  boot = {
    initrd = {
      availableKernelModules = [ "usbhid" ];
    };
    loader.grub.splashImage = lib.mkForce null;
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  system.build.OCIImage = lib.mkForce (import "${nixos-unstable}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    name = "oci-image";
    configFile = "${nixos-unstable}/nixos/modules/virtualisation/make-disk-image.nix";
    format = "qcow2";
    diskSize = 16384;
    partitionTableType = if config.oci.efi then "efi" else "legacy";
  });
}
