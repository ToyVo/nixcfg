{ lib, ... }: {
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      networking.hostName = "MacBook-Pro-Nixos";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = false;
        initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      };
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        desktops.gnome.enable = true;
      };
      hardware.asahi.peripheralFirmwareDirectory = ./firmware;
    }