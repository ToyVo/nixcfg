{
  description = "Darwin configuration";

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
          ./darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/Users/toyvo";
              imports = [ 
                ./home.nix
                ./neovim.nix
                ./alacritty.nix
                ./git.nix
                ./gpg.nix
                ./ssh.nix
                ./starship.nix
                ./zsh.nix
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
          ./darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.CollinDie = {
              home.username = "CollinDie";
              home.homeDirectory = "/Users/CollinDie";
              imports = [ 
                ./home.nix 
                ./emu.nix
                ./neovim.nix
                ./alacritty.nix
                ./git.nix
                ./gpg.nix
                ./ssh.nix
                ./starship.nix
                ./zsh.nix
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
          ./nixos.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/home/toyvo";
              imports = [ 
                ./home.nix
                ./neovim.nix
                ./alacritty.nix
                ./git.nix
                ./gpg.nix
                ./ssh.nix
                ./starship.nix
                ./zsh.nix
              ];
            };
            users.users.toyvo = {
              name = "toyvo";
              description = "Collin Diekvoss";
              home = "/home/toyvo";
            };
          }
        ];
      };
    };
  };
}
