{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets.nextcloud;
  compose = pkgs.writeText "docker-compose.yml" ''
    services:
      db:
        image: postgres:alpine
        restart: always
        volumes:
          - db:/var/lib/postgresql/data:Z
        env_file:
          - ${./db.env}

      redis:
        image: redis:alpine
        restart: always

      app:
        image: nextcloud:apache
        restart: always
        ports:
          - 0.0.0.0:8080:80
        volumes:
          - nextcloud:/var/www/html:z
        environment:
          - POSTGRES_HOST=db
          - REDIS_HOST=redis
          - NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.diekvoss.net
          - TRUSTED_PROXIES=10.1.0.1
          - MAINTENANCE_WINDOW_START=1
        env_file:
          - ${./db.env}
        depends_on:
          - db
          - redis

      cron:
        image: nextcloud:apache
        restart: always
        volumes:
          - nextcloud:/var/www/html:z
        entrypoint: /cron.sh
        depends_on:
          - db
          - redis

    volumes:
      db:
      nextcloud:
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
      allowedTCPPorts = [ 8080 ];
    };
  };
}
