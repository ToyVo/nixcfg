{ nixpkgs, home-manager, apple-silicon-support, ... }@inputs:
let
  system = "aarch64-linux";
  user = "toyvo";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/gnome.nix
    ({ lib, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;
      hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;
      networking.hostName = "MacBook-Pro-Nixos";
      boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };
      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/2905770d-0029-4fb7-8a98-644c484a084f";
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/8182-1F1C";
        fsType = "vfat";
      };
      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      hardware.video.hidpi.enable = lib.mkDefault true;
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

