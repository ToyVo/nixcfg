{
  config,
  pkgs,
  lib,
  homelab,
  ...
}:
let
  wireguardInterface = "wg0";
  wireguardInterfaceNamespace = "protonvpn0";
  inherit (config.networking) hostName;
in
{
  config = lib.mkIf config.services.qbittorrent.enable {
    services.qbittorrent = {
      serverConfig.LegalNotice.Accepted = true;
      webuiPort = homelab.${hostName}.services.qbittorrent.port;
      group = "multimedia";
    };
    networking.firewall.allowedTCPPorts = [ config.services.qbittorrent.webuiPort ];
    systemd = {
      services = {
        qbittorrent = {
          bindsTo = [ "wireguard-${wireguardInterface}.service" ];
          requires = [
            "network-online.target"
            "wireguard-${wireguardInterface}.service"
            "proxy-to-qbittorrent.service"
          ];
          serviceConfig.NetworkNamespacePath = "/var/run/netns/${wireguardInterfaceNamespace}";
        };
        # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
        proxy-to-qbittorrent = {
          enable = true;
          description = "Proxy to qBittorrent in Network Namespace";
          requires = [
            "proxy-to-qbittorrent.socket"
          ];
          after = [
            "qbittorrent.service"
            "proxy-to-qbittorrent.socket"
          ];
          unitConfig = {
            JoinsNamespaceOf = "qbittorrent.service";
          };
          serviceConfig = {
            User = "qbittorrent";
            Group = "multimedia";
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
            PrivateNetwork = "yes";
          };
        };
      };
      # allowing caddy to access qbittorrent in network namespace, a socket is necesarry
      sockets.proxy-to-qbittorrent = {
        enable = true;
        description = "Socket for Proxy to qBittorrent";
        listenStreams = [ (toString config.services.qbittorrent.webuiPort) ];
        wantedBy = [ "sockets.target" ];
      };
    };
  };
}
