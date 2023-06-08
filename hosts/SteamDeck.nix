inputs:
let
  system = "x86_64-linux";
  user = "deck";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs system; };
  modules = [
    inputs.nixvim.homeManagerModules.nixvim
    ({
      home.username = user;
      home.homeDirectory = "/home/${user}";
    })
    ../home
    ../home/git.nix
    ../home/gpg.nix
    ../home/ssh.nix
    ../home/starship.nix
    ../home/zsh.nix
    ../home/desktop-files.nix
  ];
}
