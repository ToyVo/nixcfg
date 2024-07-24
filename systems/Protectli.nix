{ lib, pkgs, ... }: {
  hardware.cpu.intel.updateMicrocode = true;
  networking = {
    hostName = "Protectli";
    networkmanager.enable = lib.mkForce false;
    useDHCP = false;
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    nat.enable = true;
    nat.enableIPv6 = true;
    nat.externalInterface = "enp1s0";
    nat.internalInterfaces = [ "enp2s0" "enp3s0" "enp4s0" ];
    # Port 53 is for DNS, 22 is for SSH, 67 is for DHCP
    firewall.interfaces.enp2s0.allowedTCPPorts = [ 53 22 ];
    firewall.interfaces.enp2s0.allowedUDPPorts = [ 53 67 ];
    firewall.interfaces.cdwifi.allowedTCPPorts = [ 53 22 ];
    firewall.interfaces.cdwifi.allowedUDPPorts = [ 53 67 ];
    firewall.interfaces.cdiot.allowedTCPPorts = [ 53 ];
    firewall.interfaces.cdiot.allowedUDPPorts = [ 53 67 ];
    firewall.interfaces.cdguest.allowedTCPPorts = [ 53 ];
    firewall.interfaces.cdguest.allowedUDPPorts = [ 53 67 ];
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules =
      [ "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
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
          DNS = [ "1.1.1.1" "1.0.0.1" ];
          PoolSize = 100;
          PoolOffset = 20;
        };
        vlan = [ "cdwifi" "cdiot" "cdguest" ];
      };
      "30-cdwifi" = {
        matchConfig.Name = "cdwifi";
        networkConfig.DHCPServer = "yes";
        dhcpServerConfig = {
          ServerAddress = "192.168.10.1/24";
          DNS = [ "1.1.1.1" "1.0.0.1" ];
          PoolSize = 100;
          PoolOffset = 20;
        };
      };
      "30-cdiot" = {
        matchConfig.Name = "cdiot";
        networkConfig.DHCPServer = "yes";
        dhcpServerConfig = {
          ServerAddress = "192.168.20.1/24";
          DNS = [ "1.1.1.1" "1.0.0.1" ];
          PoolSize = 100;
          PoolOffset = 20;
        };
      };
      "30-cdguest" = {
        matchConfig.Name = "cdguest";
        networkConfig.DHCPServer = "yes";
        dhcpServerConfig = {
          ServerAddress = "192.168.30.1/24";
          DNS = [ "1.1.1.1" "1.0.0.1" ];
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
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
}
