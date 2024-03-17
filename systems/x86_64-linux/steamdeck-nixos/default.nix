{ lib, pkgs, inputs, ... }: {
  imports = [ inputs.jovian.nixosModules.jovian ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  networking.hostName = "steamdeck-nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-amd" ];
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.efi.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services.desktopManager.plasma6.enable = true;
  # services.remote-builds.client.enable = true;
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
    options = [ "nofail" "noatime" "lazytime" "compress-force=zstd" "space_cache=v2" "autodefrag" "ssd_spread" ];
  };
  jovian = {
    devices.steamdeck.enable = true;
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "toyvo";
    steam.desktopSession = "plasma";
  };
  environment.systemPackages = with pkgs; [
    maliit-keyboard
    steam
    discord
    r2modman
    prismlauncher
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-gstreamer
        obs-vkcapture
        obs-vaapi
      ];
    })
  ];
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
  services.xserver.displayManager.sddm.enable = lib.mkForce false;
}
