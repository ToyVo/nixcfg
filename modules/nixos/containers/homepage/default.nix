{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.containerPresets.homepage;
in
{
  options.containerPresets.homepage = {
    enable = lib.mkEnableOption "Enable Homepage dashboard";
    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Port to expose Homepage dashboard on";
    };
    path = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/POOL/homepage";
      description = "Path to store Homepage dashboard data";
    };
    openFirewall = lib.mkEnableOption "Enable Homepage dashboard";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "${toString cfg.port}:3000"];
      volumes = [ "${cfg.path}/config:/app/config" ];
    };
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}

