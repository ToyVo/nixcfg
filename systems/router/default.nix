{ lib, pkgs, ... }: {
  imports = [
    ./static-leases.nix
    ./virtual-hosts.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.1.53" ];
    nat = {
      enable = true;
      externalInterface = "enp2s0";
      internalInterfaces = [ "enp3s0" "cdnet" "cdiot" "cdguest" ];
    };
    firewall = {
      enable = true;
      # Port 53 is for DNS, 22 is for SSH, 67/68 is for DHCP, 80 is for HTTP, 443 is for HTTPS
      interfaces.enp2s0.allowedTCPPorts = [ 25565 ];
      interfaces.enp3s0.allowedTCPPorts = [ 53 22 80 443 25565 ];
      interfaces.enp3s0.allowedUDPPorts = [ 53 67 68 443 ];
      interfaces.cdnet.allowedTCPPorts = [ 53 22 80 443 25565 ];
      interfaces.cdnet.allowedUDPPorts = [ 53 67 68 443 ];
      interfaces.cdiot.allowedTCPPorts = [ 53 ];
      interfaces.cdiot.allowedUDPPorts = [ 53 67 68 ];
      interfaces.cdguest.allowedTCPPorts = [ 53 80 443 25565 ];
      interfaces.cdguest.allowedUDPPorts = [ 53 67 68 ];
    };
  };
  boot = {
    loader.systemd-boot.enable = true;
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
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd = {
    network = {
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
      minecraft-server-forwarder = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Restart = "on-failure";
        };
        script = "${pkgs.socat}/bin/socat TCP-LISTEN:25565,fork,reuseaddr TCP:10.1.0.3:25565";
      };
      cfdyndns = {
        serviceConfig.Type = "oneshot";
        after = [ "network.target" ];
        script = ''
          CURRENT_IP=$(${pkgs.dig}/bin/dig +short *.diekvoss.net)
          echo "DNS is currently set to $CURRENT_IP"
          NEW_IP=$(${pkgs.iproute2}/bin/ip addr show dev enp2s0 | ${pkgs.gawk}/bin/awk '/inet / {print $2}' | cut -d '/' -f1)
          echo "The IP Address of this machine is $NEW_IP"
          if [ "$CURRENT_IP" != "$NEW_IP" ]; then
            echo "DNS Doesn't point to the right IP, checking for confirmation..."
            CONFIRM_IP=$(${pkgs.curl}/bin/curl -sS --request GET \
              --url https://api.cloudflare.com/client/v4/zones/866ce54cff10441050b4280f5c337ab1/dns_records/32d003f7bc1e418b36abe7aea91e64b4 \
              --header 'Content-Type: application/json' \
              --header 'Authorization: Bearer ${builtins.readFile ./cfapitoken}' | ${pkgs.jq}/bin/jq -r '.result.content')
            echo "DNS is currently set to $CONFIRM_IP"
            if [ "$CONFIRM_IP" != "$NEW_IP" ]; then

              BODY=$(echo '{"type":"A","name":"*.diekvoss.net","content":"'$NEW_IP'","ttl":1,"proxied":false}')
              echo "Updating DNS record to $BODY"
              ${pkgs.curl}/bin/curl -sS --request PUT \
                --url https://api.cloudflare.com/client/v4/zones/866ce54cff10441050b4280f5c337ab1/dns_records/32d003f7bc1e418b36abe7aea91e64b4 \
                --header 'authorization: Bearer ${builtins.readFile ./cfapitoken}' \
                --header 'content-type: application/json' \
                --data "$BODY"

              BODY=$(echo '{"type":"A","name":"mc.toyvo.dev","content":"'$NEW_IP'","ttl":1,"proxied":false}')
              echo "Updating DNS record to $BODY"
              ${pkgs.curl}/bin/curl -sS --request PUT \
                --url https://api.cloudflare.com/client/v4/zones/382657947fecd33d501b0cd59bd01f18/dns_records/8056d3fea28af3303fbf4519cd3173b7 \
                --header 'authorization: Bearer ${builtins.readFile ./cfapitoken}' \
                --header 'content-type: application/json' \
                --data "$BODY"

            else
              echo "DNS record is already set to the right IP, skipping update. Assuming TTL."
            fi
          else
            echo "DNS record is the right IP, skipping update."
          fi
        '';
        startAt = "*:0/5";
      };
    };
  };
  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
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
    caddy = {
      enable = true;
      email = "collin@diekvoss.com";
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
          "CF_API_KEY_FILE" = "${./cfapikey}";
          "CF_DNS_API_TOKEN_FILE" = "${./cfapitoken}";
        };
      };
    };
  };
  users.users.caddy.extraGroups = [ "acme" ];
}
