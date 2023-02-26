{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, ... }: {
    darwinConfigurations = {
      Collins-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/Users/toyvo";
              imports = [ 
                ./home/home.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/git.nix
                ./home/gpg-common.nix
                ./home/gpg-darwin.nix
                ./home/ssh.nix
                ./home/starship.nix
                ./home/zsh.nix
              ];
            };
            users.users.toyvo = {
              name = "toyvo";
              description = "Collin Diekvoss";
              home = "/Users/toyvo";
            };
          }
        ];
      };

      FQ-M-4CP7WX04 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.CollinDie = {
              home.username = "CollinDie";
              home.homeDirectory = "/Users/CollinDie";
              imports = [ 
                ./home/home.nix 
                ./home/emu.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/git.nix
                ./home/gpg-common.nix
                ./home/gpg-darwin.nix
                ./home/ssh.nix
                ./home/starship.nix
                ./home/zsh.nix
              ];
            };
            users.users.CollinDie = {
              name = "CollinDie";
              description = "Collin Diekvoss";
              home = "/Users/CollinDie";
            };
          }
        ];
      };
    };

    nixosConfigurations = {
      Collins-Thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system/thinkpad.nix
          ./system/nixos.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/home/toyvo";
              imports = [ 
                ./home/home.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/git.nix
                ./home/gpg-common.nix
                ./home/gpg-linux.nix
                ./home/ssh.nix
                ./home/starship.nix
                ./home/zsh.nix
              ];
            };
          }
        ];
      };
    };
  };
}
