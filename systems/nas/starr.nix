{ pkgs, config, ... }:
{
  sops.secrets."starr-protonvpn-US-IL-503.conf" = { };
  services = {
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        rpc-port = config.homelab.${config.networking.hostName}.services.transmission.port;
        # ip address from vpn conf file
        bind-address-ipv4 = "10.2.0.2";
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
      # number comes from conf file
      allowedUDPPorts = [ 51820 ];
      interfaces.wg0 = {
        allowedTCPPorts = [ config.services.transmission.settings.peer-port ];
        allowedUDPPorts = [ config.services.transmission.settings.peer-port ];
      };
    };
    wg-quick.interfaces.wg0 = {
      configFile = config.sops.secrets."starr-protonvpn-US-IL-503.conf".path;
      postUp = "${pkgs.iproute2}/bin/ip link set wg0 netns protonvpnwgns";
    };
  };
  systemd.services = {
    "netns@" = {
      description = "%I network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.iproute2}/bin/ip netns add %I
          ${pkgs.iproute2}/bin/ip netns exec %I ip link set lo up
        '';
        ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      };
    };
    wg-quick-wg0 = {
      bindsTo = [ "netns@protonvpnwgns.service" ];
      after = [ "netns@protonvpnwgns.service" ];
    };
    # protonvpn-wgns =
    #   let
    #     interface = "wg1";
    #     namespace = "proton0";
    #     ip = "10.2.0.2/32";
    #     confFile = config.sops.secrets."starr-protonvpn-US-IL-503.conf".path;
    #   in
    #   {
    #     bindsTo = [ "netns@${namespace}.service" ];
    #     requires = [ "network-online.target" ];
    #     after = [ "netns@${namespace}.service" ];
    #     script = ''
    #       ${pkgs.iproute2}/bin/ip link add ${interface} type wireguard
    #       ${pkgs.iproute2}/bin/ip link set ${interface} netns ${namespace}
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} address add ${ip} dev ${interface}
    #       ${pkgs.iproute2}/bin/ip netns exec ${namespace} ${pkgs.wireguard-tools}/bin/wg setconf ${interface} ${confFile}
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} link set ${interface} up
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} link set lo up
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} route add default dev ${interface}
    #     '';
    #     postStop = ''
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} route del default dev ${interface}
    #       ${pkgs.iproute2}/bin/ip -n ${namespace} link del ${interface}
    #     '';
    #   };
  };
}
