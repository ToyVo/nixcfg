{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets.nextcloud;
  compose = pkgs.writeText "docker-compose.yml" ''
    ---
    version: "2"
    services:
      homer:
        image: nextcloud/all-in-one:latest
        container_name: nextcloud-aio-mastercontainer
        volumes:
          - /mnt/POOL/nextcloud-aio-mastercontainer:/mnt/docker-aio-coinfig
          - /run/docker.sock:/var/run/docker.sock:ro
        ports:
          - 80:80
          - 443:443
          - 3478:3478
          - 8443:8443
  '';
in
{
  options.containerPresets.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud container";
    openFirewall = lib.mkEnableOption "Open firewall for nextcloud";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.docker.enable = lib.mkDefault true;
    systemd.services.homer = {
      script = ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${compose} up
      '';
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket"];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 443 3478 8443 ];
    };
  };
}
