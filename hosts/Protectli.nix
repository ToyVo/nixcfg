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
          "20-wan" = {
            matchConfig.Name = "enp1s0";
            networkConfig.DHCP = "ipv4";
            networkConfig.IPv6AcceptRA = true;
            linkConfig.RequiredForOnline = "routable";
          };
          "20-lan" = {
            matchConfig.Name = "enp2s0";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.0.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
            vlan = [ "main" "iot" "guest" ];
          };
          "30-main" = {
            matchConfig.Name = "main";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.10.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
          };
          "30-iot" = {
            matchConfig.Name = "iot";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.20.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
          };
          "30-guest" = {
            matchConfig.Name = "guest";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.30.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
          };
        };
        netdevs = {
          "10-main" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "main";
            };
            vlanConfig.Id = 10;
          };
          "10-iot" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "iot";
            };
            vlanConfig.Id = 20;
          };
          "10-guest" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "guest";
            };
            vlanConfig.Id = 30;
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
        firewall.interfaces.enp2s0.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.enp2s0.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.main.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.main.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.iot.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.iot.allowedTCPPorts = [ 53 ];
        firewall.interfaces.guest.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.guest.allowedTCPPorts = [ 53 ];
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
