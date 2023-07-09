inputs:
let
  system = "aarch64-darwin";
in inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
    ../system/darwin.nix
    ../home/toyvo.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo = {
        enable = true;
        name = "CollinDie";
        extraHomeManagerModules = [
          ../home/emu.nix
          ../home/alias-mac-apps.nix
        ];
      };
      homebrew.brews = [
        "mongosh"
        "mongodb-community@4.4"
        "mongodb-community-shell@4.4"
        "mongodb-database-tools"
      ];
      homebrew.casks = [
        "docker"
        "mongodb-compass"
      ];
      homebrew.taps = [
        "mongodb/brew"
      ];
    }
  ];
}
