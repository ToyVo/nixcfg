{ lib, config, pkgs, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    docker.enable = lib.mkEnableOption "Enable container runtime";
  };

  config = lib.mkIf cfg.docker.enable {
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        daemon.settings.dns = [ "10.1.0.1" ];
      };

      oci-containers.backend = "docker";
    };
  };
}
