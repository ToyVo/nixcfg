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
        rpc-host-whitelist = "localhost,${config.networking.hostName}.internal,transmission.diekvoss.net";
      };
    };
    sonarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostName}.services.sonarr.port;
    };
    lidarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostName}.services.lidarr.port;
    };
    radarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = config.homelab.${config.networking.hostName}.services.radarr.port;
    };
    bazarr = {
      enable = true;
      openFirewall = true;
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
    wg-quick.interfaces.wg0.configFile = config.sops.secrets."starr-protonvpn-US-IL-503.conf".path;
  };
}
