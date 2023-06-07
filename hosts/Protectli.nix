inputs:
let
  system = "x86_64-linux";
  user = "toyvo";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
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
            dhcpServerStaticLeases = [
              # Omada Controller
              {
                dhcpServerStaticLeaseConfig = {
                  Address = "192.168.0.2";
                  MACAddress = "10:27:f5:bd:04:97";
                };
              }
            ];
            vlan = [ "cdwifi" "cdiot" "cdguest" ];
          };
          "30-cdwifi" = {
            matchConfig.Name = "cdwifi";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.10.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
            dhcpServerStaticLeases = [
              # Proxmox
              {
                dhcpServerStaticLeaseConfig = {
                  Address = "192.168.10.3";
                  MACAddress = "70:85:c2:8a:53:5b";
                };
              }
              # TrueNAS VM (Proxmox)
              {
                dhcpServerStaticLeaseConfig = {
                  Address = "192.168.10.4";
                  MACAddress = "e2:8b:29:5e:56:ca";
                };
              }
              # Canon Printer
              {
                dhcpServerStaticLeaseConfig = {
                  Address = "192.168.10.4";
                  MACAddress = "c4:ac:59:a6:63:33";
                };
              }
              # Docker VM (Proxmox)
              {
                dhcpServerStaticLeaseConfig = {
                  Address = "192.168.10.6";
                  MACAddress = "7a:8d:bd:a3:66:ba";
                };
              }
            ];
          };
          "30-cdiot" = {
            matchConfig.Name = "cdiot";
            networkConfig.DHCPServer = "yes";
            dhcpServerConfig = {
              ServerAddress = "192.168.20.1/24";
              DNS = ["1.1.1.1" "1.0.0.1"];
              PoolSize = 100;
              PoolOffset = 20;
            };
          };
          "30-cdguest" = {
            matchConfig.Name = "cdguest";
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
          "10-cdwifi" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "cdwifi";
            };
            vlanConfig.Id = 10;
          };
          "10-cdiot" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "cdiot";
            };
            vlanConfig.Id = 20;
          };
          "10-cdguest" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "cdguest";
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
        firewall.interfaces.enp2s0.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.enp2s0.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.cdwifi.allowedTCPPorts = [ 53 22 ];
        firewall.interfaces.cdwifi.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.cdiot.allowedTCPPorts = [ 53 ];
        firewall.interfaces.cdiot.allowedUDPPorts = [ 53 67 ];
        firewall.interfaces.cdguest.allowedTCPPorts = [ 53 ];
        firewall.interfaces.cdguest.allowedUDPPorts = [ 53 67 ];
      };
    })
    inputs.nixpkgs.nixosModules.notDetected
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
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
