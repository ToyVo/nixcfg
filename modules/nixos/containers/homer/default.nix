{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.containerPresets.homer;
  compose = pkgs.writeText "docker-compose.yml" ''
    ---
    version: "2"
    services:
      homer:
        image: b4bz/homer
        container_name: homer
        volumes:
          - ${./assets}:/www/assets
        ports:
          - ${cfg.port}:8080
        user: 1000:1000 # default
        environment:
          - INIT_ASSETS=1 # default
  '';
in
{
  options.containerPresets.homer = {
    enable = lib.mkEnableOption "Enable Homer dashboard";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8787;
      description = "Port to expose Homer dashboard on";
    };
    openFirewall = lib.mkEnableOption "Enable Homer dashboard";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.docker.enable = lib.mkDefault true;
    systemd.services.homer = {
      script = ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${compose}
      '';
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket"];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
