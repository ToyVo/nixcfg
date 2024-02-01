{ lib, config, pkgs, ... }:
let
  cfg = config.cd.containers;
in
{
  options.cd.containers = {
    enable = lib.mkEnableOption "Enable container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualization = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      oci-containers.backend = "podman";
    };
  };
}
