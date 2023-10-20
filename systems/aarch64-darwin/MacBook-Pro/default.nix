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

    ({ pkgs, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
      environment.systemPackages = with pkgs; [
        openscad
      ];
      homebrew.casks = [
        { name = "prusaslicer"; greedy = true; }
      ];
      homebrew.masApps = {
        "Yubico Authenticator" = 1497506650;
        "Wireguard" = 1451685025;
      };
    })
  ];
}
