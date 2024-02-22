{ lib, config, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    docker.enable = lib.mkEnableOption "Enable container runtime";
  };

  config = lib.mkIf cfg.docker.enable {
    environment.systemPackages = with lib; [
      docker-compose
    ];
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      oci-containers.backend = "docker";
    };
  };
}
