{ pkgs, config, ... }:
{
  sops.secrets."starr-protonvpn-US-IL-503.conf" = { };
  services = {
    deluge = {
      enable = true;
      web = {
        enable = true;
        openFirewall = true;
        port = config.homelab.${config.networking.hostname}.services.deluge.port;
      };
    };
    sonarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostname}.services.sonarr.port;
    };
    lidarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostname}.services.lidarr.port;
    };
    radarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostname}.services.radarr.port;
    };
    bazarr = {
      enable = true;
      openFirewall = true;
      listenPort = config.homelab.${config.networking.hostname}.services.bazarr.port;
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostname}.services.prowlarr.port;
    };
    readarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostname}.services.readarr.port;
    };
    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = config.homelab.${config.networking.hostname}.services.flaresolverr.port;
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
  systemd = {
    # creating network namespace
    services = {
      "netns@" = {
        description = "%I network namespace";
        before = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
          ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
        };
      };

      # setting up wireguard interface within network namespace
      wg = {
        description = "wg network interface";
        bindsTo = [ "netns@wg.service" ];
        requires = [ "network-online.target" ];
        after = [ "netns@wg.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            with pkgs;
            writers.writeBash "wg-up" ''
              see -e
              ${iproute2}/bin/ip link add wg0 type wireguard
              ${iproute2}/bin/ip link set wg0 netns wg
              ${iproute2}/bin/ip -n wg address add 10.2.0.2/32 dev wg0
              # ${iproute2}/bin/ip -n wg -6 address add <ipv6 VPN addr/cidr> dev wg0
              ${iproute2}/bin/ip netns exec wg \
                ${wireguard-tools}/bin/wg setconf wg0 ${config.sops.secrets."starr-protonvpn-US-IL-503.conf".path}
              ${iproute2}/bin/ip -n wg link set wg0 up
              # need to set lo up as network namespace is started with lo down
              ${iproute2}/bin/ip -n wg link set lo up
              ${iproute2}/bin/ip -n wg route add default dev wg0
              # ${iproute}/bin/ip -n wg -6 route add default dev wg0
            '';
          ExecStop =
            with pkgs;
            writers.writeBash "wg-down" ''
              ${iproute2}/bin/ip -n wg route del default dev wg0
              # ${iproute2}/bin/ip -n wg -6 route del default dev wg0
              ${iproute2}/bin/ip -n wg link del wg0
            '';
        };
      };

      # binding deluged to network namespace
      deluged = {
        bindsTo = [ "netns@wg.service" ];
        requires = [
          "network-online.target"
          "wg.service"
        ];
        serviceConfig.NetworkNamespacePath = [ "/var/run/netns/wg" ];
      };

      # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
      "proxy-to-deluged" = {
        enable = true;
        description = "Proxy to Deluge Daemon in Network Namespace";
        requires = [
          "deluged.service"
          "proxy-to-deluged.socket"
        ];
        after = [
          "deluged.service"
          "proxy-to-deluged.socket"
        ];
        unitConfig = {
          JoinsNamespaceOf = "deluged.service";
        };
        serviceConfig = {
          User = "deluge";
          Group = "deluge";
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
          PrivateNetwork = "yes";
        };
      };
    };

    # allowing delugeweb to access deluged in network namespace, a socket is necesarry
    sockets."proxy-to-deluged" = {
      enable = true;
      description = "Socket for Proxy to Deluge Daemon";
      listenStreams = [ "58846" ];
      wantedBy = [ "sockets.target" ];
    };
  };
}
