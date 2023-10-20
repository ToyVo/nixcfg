{ inputs, ... }:
let
  system = "aarch64-darwin";
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
../../../modules/darwin/cd-darwin
../../../modules/nixos/toyvo

    ({pkgs, ...}: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo = {
        enable = true;
        name = "CollinDie";
        extraHomeManagerModules = [
../../../modules/home/emu

        ];
      };

      homebrew = {
        brews = [
          "mongosh"
          "mongodb-community@4.4"
          "mongodb-community-shell@4.4"
          "mongodb-database-tools"
        ];
        casks = [
          { name = "docker"; greedy = true; }
          { name = "mongodb-compass"; greedy = true; }
          { name = "slack"; greedy = true; }
        ];
        taps = [
          "mongodb/brew"
        ];
        masApps = {
          "Yubico Authenticator" = 1497506650;
        };
      };
    })
  ];
}
