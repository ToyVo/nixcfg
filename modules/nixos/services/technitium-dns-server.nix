{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.technitium-dns-server;
in
{
  options.services.technitium-dns-server = {
    enable = lib.mkEnableOption "Technitium DNS Server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5380;
      description = "Web UI / HTTP API listen port";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/technitium-dns-server";
      description = "State directory for config, zones, and logs";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall for DNS (UDP/TCP 53) and web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.technitium-dns-server = {
      isSystemUser = true;
      uid = config.ids.uids.technitium-dns-server;
      group = "technitium-dns-server";
    };
    users.groups.technitium-dns-server = {
      gid = config.ids.gids.technitium-dns-server;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 technitium-dns-server technitium-dns-server -"
    ];

    systemd.services.technitium-dns-server = {
      description = "Technitium DNS Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        User = "technitium-dns-server";
        Group = "technitium-dns-server";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${lib.getExe pkgs.technitium-dns-server}";
        Restart = "on-failure";
        RestartSec = "5s";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        StateDirectory = "technitium-dns-server";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.port
        53 # DNS over TCP
      ];
      allowedUDPPorts = [
        53 # DNS over UDP
      ];
    };
  };
}
