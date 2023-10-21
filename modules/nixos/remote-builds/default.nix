{ lib, config, ... }: {
  options.cd.remote-builds = {
    server.enable = lib.mkEnableOption "Enable remote-builds server";
    client.enable = lib.mkEnableOption "Enable remote-builds client";
  };

  config = {
    users.users.nixremote = lib.mkIf config.cd.remote-builds.server.enable {
      name = "nixremote";
      home = "/home/nixremote";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ lib.fileContents ./nixremote_ed25519.pub ];
      isNormalUser = true;
    };

    cd.users.root.enable = config.cd.remote-builds.client.enable;

    home-manager.users.root.programs.ssh = lib.mkIf config.cd.remote-builds.client.enable {
      enable = lib.mkDefault true;
      matchBlocks."builder" = {
        user = "nixremote";
        hostname = "10.1.0.3";
        identitiesOnly = true;
        identityFile = "${./nixremote_ed25519}";
      };
    };

    nix.trustedUsers = lib.mkIf config.cd.remote-builds.server.enable [ "nixremote" ];
    nix.buildMachines = lib.mkIf config.cd.remote-builds.client.enable [
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
    nix.distributedBuilds = config.cd.remote-builds.client.enable;
    nix.extraOptions = lib.mkIf config.cd.remote-builds.client.enable ''
      builders-use-substitutes = true
    '';
  };
}
