{ lib, config, ... }:
let
  cfg = config.containerPresets;
in
{
  imports = [ ./nextcloud.nix ];

  options.containerPresets = {
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
