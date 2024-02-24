{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.containerPresets.homer;
  compose = pkgs.writeText "compose.yml" ''
    ---
    version: "2"
    services:
      homer:
        image: b4bz/homer
        container_name: homer
        volumes:
          - ${./assets}:/www/assets
        ports:
          - ${toString cfg.port}:8080
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
    containerPresets.podman.enable = lib.mkDefault true;
    systemd.services.homer = {
      script = ''
        ${pkgs.podman-compose}/bin/podman-compose -f ${compose} up
      '';
      wantedBy = ["multi-user.target"];
      after = ["podman.service" "podman.socket"];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
