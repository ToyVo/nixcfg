{ nixpkgs, home-manager, ... }@inputs:
let
  system = "x86_64-linux";
  user = "toyvo";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      networking.networkmanager.enable = lib.mkForce false;
      boot = {
        initrd.availableKernelModules =
          [ "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
      };
      swapDevices = [ ];
      hardware.cpu.intel.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      systemd.network = {
        enable = true;
        networks = {
          "20-WAN" = {
            matchConfig.Name = "enp1s0";
            networkConfig.DHCP = "yes";
          };
          "21-LAN" = {
            matchConfig.Name = "enp2s0";
            networkConfig = {
              Address = "192.168.0.1/24";
              DNS = "1.1.1.1";
              VLAN = "enp2s0.20";
            };
          };
          "22-IOT" = {
            matchConfig.Name = "enp2s0.20";
            networkConfig = {
              Address = "192.168.20.1/24";
              DNS = "1.1.1.1";
            };
            routingPolicyRuleConfig = {
              From = "192.168.20.0/24";
              Table = "iot";
            };
          };
        };
        netdevs = {
          "22-IOT" = {
            netdevConfig = {
              Name = "enp2s0.20";
              Kind = "vlan";
            };
            vlanConfig.Id = 20;
          };
        };
      };
      networking = {
        hostName = "Protectli";
        useDHCP = false;
        nameservers = [ "1.1.1.1" "1.0.0.1" ];
        nat.enable = true;
        nat.enableIPv6 = true;
        nat.externalInterface = "enp1s0";
        nat.internalInterfaces = [ "enp2s0" "enp3s0" "enp4s0" ];
      };
    })
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
