{nixpkgs, home-manager}:
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [ 
    ({...}:{
      home.username = "deck";
      home.homeDirectory = "/home/deck";
    })
    ../home/home-common.nix
    ../home/home-linux.nix
    ../home/neovim.nix
    ../home/alacritty.nix
    ../home/kitty.nix
    ../home/git.nix
    ../home/gpg-common.nix
    ../home/gpg-linux.nix
    ../home/ssh.nix
    ../home/starship.nix
    ../home/zsh.nix
    ../home/desktop-files.nix
  ];
}
