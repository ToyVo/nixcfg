{ inputs, ... }:
let
  system = "aarch64-darwin";
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    ../../../modules/darwin/cd-darwin
    ../../../modules/darwin/users/toyvo
    {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cd.defaults.enable = true;
      cd.users.toyvo.enable = true;
      homebrew.casks = [
        { name = "prusaslicer"; greedy = true; }
        { name = "google-chrome"; greedy = true; }
      ];
    }
  ];
}
