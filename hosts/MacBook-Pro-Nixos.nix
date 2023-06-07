{ nixpkgs, home-manager, apple-silicon-support, ... }@inputs:
let
  system = "aarch64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ../system/gnome.nix
    ../system/filesystem/btrfs.nix
    ({ lib, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;
      hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;
      networking.hostName = "MacBook-Pro-Nixos";
      boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };
      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
    })
    apple-silicon-support.nixosModules.apple-silicon-support
    nixpkgs.nixosModules.notDetected
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/neovim
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    }
  ];
}

