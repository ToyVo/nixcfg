inputs:
let
  system = "aarch64-darwin";
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
    ../darwin
    ../home/toyvo
    ({pkgs, ...}: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo = {
        enable = true;
        name = "CollinDie";
        extraHomeManagerModules = [
          ../home/toyvo/emu.nix
        ];
      };

      environment.systemPackages = with pkgs; [
        slack
      ];

      homebrew = {
        brews = [
          "mongosh"
          "mongodb-community@4.4"
          "mongodb-community-shell@4.4"
          "mongodb-database-tools"
        ];
        casks = [
          "docker"
          "mongodb-compass"
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
