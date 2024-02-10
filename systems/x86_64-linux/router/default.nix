{ lib, pkgs, ... }: {
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.1.53" ];
    nat.enable = true;
    nat.externalInterface = "enp2s0";
    nat.internalInterfaces = [ "enp3s0" "cdnet" "cdiot" "cdguest" ];
    firewall = {
      enable = true;
      interfaces.enp3s0.allowedTCPPorts = [ 53 22 80 443 ];
      interfaces.enp3s0.allowedUDPPorts = [ 53 67 68 ];
      interfaces.cdnet.allowedTCPPorts = [ 53 22 80 443 ];
      interfaces.cdnet.allowedUDPPorts = [ 53 67 68 ];
      interfaces.cdiot.allowedTCPPorts = [ 53 ];
      interfaces.cdiot.allowedUDPPorts = [ 53 67 68 ];
      interfaces.cdguest.allowedTCPPorts = [ 53 ];
      interfaces.cdguest.allowedUDPPorts = [ 53 67 68 ];
    };
  };
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
  };
  systemd.network = {
    enable = true;
    networks."10-wan0" = {
      matchConfig.Name = "enp2s0";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config = {
        UseDNS = false;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    networks."20-lan" = {
      matchConfig.Name = "enp3s0";
      address = [ "10.1.0.1/24" ];
      vlan = [ "cdnet" "cdiot" "cdguest" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
        MulticastDNS = true;
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      dhcpServerStaticLeases = [
        # Omada Controller
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.2";
            MACAddress = "10:27:f5:bd:04:97";
          };
        }
        # NCase
        # if changing ip, change A record on cloudflare
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.3";
            MACAddress = "70:85:c2:8a:53:5b";
          };
        }
        # Canon Printer (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.4";
            MACAddress = "c4:ac:59:a6:63:33";
          };
        }
        # HP Printer (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.5";
            MACAddress = "7c:4d:8f:91:d3:9f";
          };
        }
        # Backup / testing router (Ethernet)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.6";
            # other ethernet ports end with f1, f2, f3
            MACAddress = "00:e0:67:2c:15:f0";
          };
        }
        # rpi4b8a (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.7";
            # ethernet port ends with 3b
            MACAddress = "e4:5f:01:ad:81:3d";
          };
        }
        # rpi4b8b (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.8";
            # ethernet port ends with da
            MACAddress = "e4:5f:01:ad:a0:db";
          };
        }
        # rpi4b8c (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.9";
            # ethernet port ends with 27
            MACAddress = "e4:5f:01:ad:9f:28";
          };
        }
        # rpi4b4a (wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.10";
            # ethernet port ends with 24
            MACAddress = "dc:a6:32:09:ce:25";
          };
        }
        # Mac Mini m1 (Wifi)
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.11";
            # ethernet port ends with 24
            MACAddress = "4c:20:b8:df:d1:5b";
          };
        }
      ];
      linkConfig.RequiredForOnline = "no";
    };
    netdevs."21-cdnet" = {
      netdevConfig = {
        Name = "cdnet";
        Kind = "vlan";
      };
      vlanConfig.Id = 10;
    };
    netdevs."22-cdiot" = {
      netdevConfig = {
        Name = "cdiot";
        Kind = "vlan";
      };
      vlanConfig.Id = 20;
    };
    netdevs."23-cdguest" = {
      netdevConfig = {
        Name = "cdguest";
        Kind = "vlan";
      };
      vlanConfig.Id = 30;
    };
    networks."21-cdnet" = {
      matchConfig.Name = "cdnet";
      address = [ "10.1.10.1/24" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      linkConfig.RequiredForOnline = "no";
    };
    networks."22-cdiot" = {
      matchConfig.Name = "cdiot";
      address = [ "10.1.20.1/24" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      linkConfig.RequiredForOnline = "no";
    };
    networks."23-cdguest" = {
      matchConfig.Name = "cdguest";
      address = [ "10.1.30.1/24" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      linkConfig.RequiredForOnline = "no";
    };
  };
  services = {
    openssh.openFirewall = false;
    resolved = {
      enable = true;
      extraConfig = ''
        DNSStubListenerExtra=10.1.0.1
      '';
    };
    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings.dns = {
        bind_hosts = [ "127.0.1.53" ];
        bootstrap_dns = [ "9.9.9.9" ];
      };
    };
    cfdyndns = {
      enable = true;
      email = "collin@diekvoss.com";
      records = [
        "*.diekvoss.net"
      ];
      apikeyFile = "${../../../secrets/cfapikey}";
      apiTokenFile = "${../../../secrets/cfapitoken}";
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "adguard.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.1:3000";
            recommendedProxySettings = true;
          };
        };
        "canon.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.4:443";
            recommendedProxySettings = true;
          };
        };
        "nextcloud.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          locations."/" = {
            proxyPass = "https://10.1.0.3:443";
            recommendedProxySettings = true;
          };
        };
        "octoprint.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.7:5000";
            recommendedProxySettings = true;
            proxyWebsockets = true;
          };
          locations."/webcam/" = {
            proxyPass = "http://10.1.0.7:8080";
          };
        };
        "omada.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.2:80";
            recommendedProxySettings = true;
          };
        };
        "portal.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.3:8787";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "diekvoss.net" = {
        email = "collin@diekvoss.com";
        extraDomainNames = [ "*.diekvoss.net" ];
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_API_EMAIL_FILE" = "${pkgs.writeText "cfemail" ''
            collin@diekvoss.com
          ''}";
          "CF_API_KEY_FILE" = "${../../../secrets/cfapikey}";
          "CF_DNS_API_TOKEN_FILE" = "${../../../secrets/cfapitoken}";
        };
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
}
