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
      cd.users.toyvo.enable = true;
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
