{ pkgs, config, ... }:
let
  wireguardInterface = "wg0";
  wireguardInterfaceNamespace = "protonvpn0";
in
{
  sops.secrets."protonvpn-US-IL-503.key" = { };
  services = {
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        rpc-port = config.homelab.${config.networking.hostName}.services.transmission.port;
        # ip address from vpn conf file
        bind-address-ipv4 = "0.0.0.0";
        # expose web interface on all interfaces
        rpc-bind-address = "0.0.0.0";
        # allow connections from localhost and lan
        rpc-whitelist = "127.0.0.1,10.1.0.*";
        # allow connecting from domain names
        rpc-host-whitelist = "${config.networking.hostName}.internal,transmission.diekvoss.net";
        download-dir = "/mnt/POOL/transmission/Downloads";
      };
      group = "multimedia";
    };
    sonarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.sonarr.port;
    };
    lidarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.lidarr.port;
      package = pkgs.lidarr.overrideAttrs rec {
        version = "2.12.4.4658";
        src = pkgs.fetchurl {
          url = "https://github.com/lidarr/Lidarr/releases/download/v${version}/Lidarr.master.${version}.linux-core-x64.tar.gz";
          sha256 = "sha256-ttbQj6GYuKedDEdF8vUZcmc0AluZS6pPC5GCQTUu7OM=";
        };
      };
    };
    radarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.radarr.port;
    };
    bazarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      listenPort = config.homelab.${config.networking.hostName}.services.bazarr.port;
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostName}.services.prowlarr.port;
    };
    readarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = config.homelab.${config.networking.hostName}.services.readarr.port;
    };
    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = config.homelab.${config.networking.hostName}.services.flaresolverr.port;
      package = pkgs.flaresolverr.overrideAttrs (
        finalAttrs: previousAttrs: rec {
          version = "3.3.24";
          src = pkgs.fetchFromGitHub {
            owner = "FlareSolverr";
            repo = "FlareSolverr";
            rev = "v${version}";
            hash = "sha256-BIV5+yLTgVQJtxi/F9FwtZ4pYcE2vGHmEgwigMtqwD8=";
          };
        }
      );
    };
  };
  networking = {
    firewall = {
      interfaces.${wireguardInterface} = {
        allowedTCPPorts = [ config.services.transmission.settings.peer-port ];
        allowedUDPPorts = [ config.services.transmission.settings.peer-port ];
      };
    };
    wireguard.interfaces.${wireguardInterface} = {
      privateKeyFile = config.sops.secrets."protonvpn-US-IL-503.key".path;
      ips = [ "10.2.0.2/32" ];
      peers = [
        {
          publicKey = "Ad0UnBi3NeIgVpM1baC8HAp6wfSli0wGS1OCmS7uYRo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "79.127.187.156:51820";
        }
      ];
      interfaceNamespace = wireguardInterfaceNamespace;
      preSetup = ''ip netns add "${wireguardInterfaceNamespace}"'';
      postSetup = ''
        ip -n "${wireguardInterfaceNamespace}" link set up dev "lo"
        ip -n "${wireguardInterfaceNamespace}" route add default dev "${wireguardInterface}"
      '';
      preShutdown = ''ip -n "${wireguardInterfaceNamespace}" route del default dev "${wireguardInterface}"'';
      postShutdown = ''ip netns del "${wireguardInterfaceNamespace}"'';
    };
  };
  environment.etc."netns/${wireguardInterfaceNamespace}/resolv.conf".text = "nameserver 10.2.0.1";
  systemd = {
    services = {
      transmission = {
        bindsTo = [ "wireguard-${wireguardInterface}.service" ];
        requires = [
          "network-online.target"
          "wireguard-${wireguardInterface}.service"
        ];
        serviceConfig.NetworkNamespacePath = "/var/run/netns/${wireguardInterfaceNamespace}";
      };
      # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
      proxy-to-transmission = {
        enable = true;
        description = "Proxy to Transmission in Network Namespace";
        requires = [
          "transmission.service"
          "proxy-to-transmission.socket"
        ];
        after = [
          "transmission.service"
          "proxy-to-transmission.socket"
        ];
        unitConfig = {
          JoinsNamespaceOf = "transmission.service";
        };
        serviceConfig = {
          User = "transmission";
          Group = "multimedia";
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
          PrivateNetwork = "yes";
        };
      };
    };
    # allowing caddy to access transmission in network namespace, a socket is necesarry
    sockets.proxy-to-transmission = {
      enable = true;
      description = "Socket for Proxy to Transmission";
      listenStreams = [ (toString config.services.transmission.settings.rpc-port) ];
      wantedBy = [ "sockets.target" ];
    };
  };
}
