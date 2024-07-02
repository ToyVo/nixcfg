{ config, lib, ... }:
let
  cfg = config.services.remote-builds;
in
{
  options.services.remote-builds = {
    server.enable = lib.mkEnableOption "Enable remote-builds server";
    client.enable = lib.mkEnableOption "Enable remote-builds client";
  };

  config = {
    users = lib.mkIf cfg.server.enable {
      users.nixremote = {
        name = "nixremote";
        group = "nixremote";
        openssh.authorizedKeys.keyFiles = [
          ../../../secrets/nixremote_ed25519.pub
        ];
        isSystemUser = true;
      };
      groups.nixremote = { };
    };

    nix.settings.trusted-users = lib.mkIf cfg.server.enable [ "nixremote" ];

    nix.buildMachines = lib.mkIf cfg.client.enable [
      {
        hostName = "builder";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }
    ];
    nix.distributedBuilds = cfg.client.enable;
    nix.extraOptions = lib.mkIf cfg.client.enable ''
      builders-use-substitutes = true
    '';
  };
}

