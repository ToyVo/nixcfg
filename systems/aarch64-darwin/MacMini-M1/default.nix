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
    ../../../darwin
    ../../../home/toyvo
    {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;

      homebrew.casks = [
        { name = "prusaslicer"; greedy = true; }
        { name = "google-chrome"; greedy = true; }
      ];
    }
  ];
}
