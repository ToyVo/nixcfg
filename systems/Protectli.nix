{ lib, pkgs, ... }:
{
  hardware.cpu.intel.updateMicrocode = true;
  networking = {
    hostName = "Protectli";
    networkmanager.enable = lib.mkForce false;
    useDHCP = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    nat = {
      enable = true;
      externalInterface = "enp1s0";
      internalInterfaces = [
        "br0"
      ];
    };
    # Port 53 is for DNS, 22 is for SSH, 67 is for DHCP
    firewall.interfaces = {
      br0 = {
        allowedTCPPorts = [
          53
          22
        ];
        allowedUDPPorts = [
          53
          67
        ];
      };
    };
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd.network = {
    enable = true;
    networks = {
      wan0 = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        networkConfig.IPv6AcceptRA = true;
        linkConfig.RequiredForOnline = "routable";
      };
      lan0 = {
        matchConfig.Name = "enp2s0 enp3s0 enp4s0";
        networkConfig.Bridge = "br0";
      };
      br0 = {
        matchConfig.Name = "br0";
        networkConfig.Address = "192.168.0.1/24";
      };
    };
    netdevs = {
      br0.netdevConfig = {
        Kind = "bridge";
        Name = "br0";
        MACAddress = "none";
      };
    };
    links = {
      br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
  };
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [ "br0" ];
          dhcp-socket-type = "raw";
        };
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
          lfc-interval = 3600; # 1 hour in seconds
        };
        authoritative = true;
        renew-timer = 3600 * 5;
        rebind-timer = 3600 * 8;
        valid-lifetime = 3600 * 9;
        option-data = [
          {
            name = "domain-name-servers";
            data = "1.1.1.1, 1.0.0.1";
          }
          {
            name = "domain-search";
            data = "diekvoss.internal, diekvoss.net, diekvoss.com";
          }
        ];
        subnet4 = [
          {
            id = 1;
            subnet = "192.168.0.0/24";
            pools = [
              {
                pool = "192.168.0.64 - 192.168.0.254";
              }
            ];
            option-data = [
              {
                name = "routers";
                data = "192.168.0.1";
              }
            ];
          }
        ];
        loggers = [
          {
            name = "kea-dhcp4";
            output_options = [
              {
                output = "/var/lib/kea/kea-dhcp4.log";
                maxver = 10;
              }
            ];
            severity = "INFO";
          }
        ];
      };
    };
  };
}
