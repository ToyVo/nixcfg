{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets.nextcloud;
  compose = pkgs.writeText "docker-compose.yml" ''
    services:
      nextcloud-aio-mastercontainer:
        image: nextcloud/all-in-one:latest
        init: true
        restart: always
        container_name: nextcloud-aio-mastercontainer
        volumes:
          - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
          - /var/run/docker.sock:/var/run/docker.sock:ro
        ports:
          - 80:80
          - 8080:8080
          - 8443:8443
        environment:
          # - APACHE_PORT=11000
          # - APACHE_IP_BINDING=0.0.0.0
          # I use Cloudflare for my DNS, so I need to set the following to true
          # - SKIP_DOMAIN_VALIDATION=true

    volumes:
      nextcloud_aio_mastercontainer:
        name: nextcloud_aio_mastercontainer
  '';
in
{
  options.containerPresets.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud container";
    openFirewall = lib.mkEnableOption "Open firewall for nextcloud";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.docker.enable = lib.mkDefault true;
    systemd.services.nextcloud = {
      script = ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${compose} up
      '';
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket"];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 443 3478 8080 8443 11000 ];
      allowedUDPPorts = [ 443 ];
    };
  };
}
