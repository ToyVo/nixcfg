{ lib, config, ... }:
let
  cfg = config.cd.containers;
in
{
  imports = [ ./nextcloud.nix ];

  options.cd.containers = {
    enable = lib.mkEnableOption "Enable container runtime";
  };

  config = lib.mkIf cfg.enable {
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
