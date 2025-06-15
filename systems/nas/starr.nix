{ pkgs, config, ... }:
{
  sops.secrets = {
    "starr-protonvpn-US-IL-503.conf" = { };
    "starr-protonvpn-US-IL-503.privatekey" = { };
    deluge-auth.owner = "deluge";
  };
  services = {
    deluge = {
      enable = true;
      declarative = true;
      config = {
        enabled_plugins = [ "Label" ];
        outgoing_interface = "wg0";
      };
      authFile = config.sops.secrets.deluge-auth.path;
      web = {
        enable = true;
        openFirewall = true;
        port = config.homelab.${config.networking.hostName}.services.deluge.port;
      };
    };
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        rpc-port = config.homelab.${config.networking.hostName}.services.transmission.port;
        bind-address-ipv4 = "10.2.0.2";
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "127.0.0.1,10.1.0.*";
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
    firewall.allowedUDPPorts = [ 51820 ];
    wg-quick.interfaces.wg0.configFile = config.sops.secrets."starr-protonvpn-US-IL-503.conf".path;
  };
}
