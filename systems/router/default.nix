{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./kea.nix
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
      internalInterfaces = [
        "br0"
      ];
    };
    firewall = {
      enable = true;
      # Port 53 is for DNS, 22 is for SSH, 67/68 is for DHCP, 80 is for HTTP, 443 is for HTTPS
      interfaces.br0 = {
        allowedTCPPorts = [
          53
          22
          80
          443
        ];
        allowedUDPPorts = [
          53
          67
          68
          443
        ];
      };
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
  virtualisation.containers.enable = true;
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  systemd = {
    network = {
      enable = true;
      networks.wan0 = {
        matchConfig.Name = "enp2s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          UseDNS = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      networks.lan0 = {
        matchConfig.Name = "enp3s0 enp4s0 enp5s0";
        networkConfig.Bridge = "br0";
      };
      networks.br0 = {
        matchConfig.Name = "br0";
        networkConfig = {
          Address = "10.1.0.1/24";
          IPMasquerade = "ipv4";
          MulticastDNS = true;
        };
      };
      netdevs.br0.netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "none";
      };
      links.br0 = {
        matchConfig.OriginalName = "br0";
        linkConfig.MACAddressPolicy = "none";
      };
    };
    services = {
      cfdyndns = {
        serviceConfig.Type = "oneshot";
        after = [ "network.target" ];
        path = with pkgs; [
          curl
          iproute2
          gawk
          dig
          jq
        ];
        script = ''
          declare -a DOMAINS=(
            "*.diekvoss.net"
          )
          TOKEN=$(cat ${config.sops.secrets.cloudflare_w_dns_r_zone_token.path})

          function put_record() {
            curl -sS -X PUT \
              -H "Content-Type: application/json" \
              -H "Authorization: Bearer $TOKEN" \
              -d "{\"type\":\"A\",\"name\":\"$3\",\"content\":\"$4\",\"ttl\":1,\"proxied\":false}" \
              "https://api.cloudflare.com/client/v4/zones/$1/dns_records/$2"
          }

          function get_ip() {
            curl -sS \
               -H "Content-Type: application/json" \
               -H "Authorization: Bearer $TOKEN" \
               https://api.cloudflare.com/client/v4/zones/$1/dns_records/$2 | jq -r '.result.content'
          }

          function get_zone() {
            curl -sS \
               -H "Content-Type: application/json" \
               -H "Authorization: Bearer $TOKEN" \
               https://api.cloudflare.com/client/v4/zones?name=$1 | jq -r '.result.[].id'
          }

          function get_record() {
            curl -sS \
               -H "Content-Type: application/json" \
               -H "Authorization: Bearer $TOKEN" \
               https://api.cloudflare.com/client/v4/zones/$1/dns_records?name=$2 | jq -r '.result.[].id'
          }

          NEW_IP=$(ip addr show dev enp2s0 | awk '/inet / {print $2}' | cut -d '/' -f1)
          echo "The IP Address of this machine is $NEW_IP"
          for DOMAIN in "''${DOMAINS[@]}"
          do
              CURRENT_IP=$(dig +short $DOMAIN)
              echo "DNS for $DOMAIN is currently set to $CURRENT_IP"
              if [ "$CURRENT_IP" != "$NEW_IP" ]; then
                echo "DNS for $DOMAIN Doesn't point to $NEW_IP, checking for confirmation..."
                BASE_DOMAIN=$(awk -F'.' '{gsub(/^\*\./, ""); print $(NF-1) "." $NF}' <<< "$DOMAIN")
                echo "Base for $DOMAIN is $BASE_DOMAIN"
                ZONE=$(get_zone "$BASE_DOMAIN")
                echo "Zone ID for $BASE_DOMAIN is $ZONE"
                RECORD=$(get_record "$ZONE" "$DOMAIN")
                echo "Record ID for $DOMAIN is $RECORD"
                CONFIRM_IP=$(get_ip "$ZONE" "$RECORD")
                echo "DNS for $DOMAIN is confirmed set to $CONFIRM_IP"
                if [ "$CONFIRM_IP" != "$NEW_IP" ]; then
                  echo "Updating DNS record for $DOMAIN to $NEW_IP"
                  put_record "$ZONE" "$RECORD" "$DOMAIN" "$NEW_IP"
                else
                  echo "DNS record for $DOMAIN is already set to $NEW_IP, skipping update. Assuming TTL."
                fi
              else
                echo "DNS record for $DOMAIN is $NEW_IP, skipping update."
              fi
          done
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
          "CF_API_KEY_FILE" = config.sops.secrets.cloudflare_global_api_key.path;
          "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_w_dns_r_zone_token.path;
        };
      };
    };
  };
  sops.secrets = {
    cloudflare_global_api_key = { };
    cloudflare_w_dns_r_zone_token = { };
  };
  users.users.caddy.extraGroups = [ "acme" ];
}
