{ inputs, ... }:
let
  system = "aarch64-darwin";
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ({ pkgs, ... }: {
      imports = [
        ../../../modules/darwin/cd-darwin
        ../../../modules/darwin/users/toyvo
      ];
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cd.defaults.enable = true;
      cd.users.toyvo = {
        enable = true;
        name = "CollinDie";
        extraHomeManagerModules = [
          ../../../modules/home/emu
          {
            cd.emu.enable = true;
          }
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
