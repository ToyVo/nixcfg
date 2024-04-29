{ lib, config, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    podman.enable = lib.mkEnableOption "Enable podman runtime";
  };

  config = lib.mkIf cfg.podman.enable {
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
