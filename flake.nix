{
  description = "Collin Diekvoss Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, darwin, nixos-hardware, ... }: {
    darwinConfigurations = {
      Collins-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/common.nix
          ./system/darwin.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/Users/toyvo";
              imports = [ 
                ./home/home-common.nix
                ./home/home-darwin.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/kitty.nix
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
          ./system/common.nix
          ./system/darwin.nix
          ./system/work.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.CollinDie = {
              home.username = "CollinDie";
              home.homeDirectory = "/Users/CollinDie";
              imports = [ 
                ./home/home-common.nix 
                ./home/home-darwin.nix
                ./home/emu.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/kitty.nix
                ./home/git.nix
                ./home/gpg-common.nix
                ./home/gpg-darwin.nix
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
          ./system/common.nix
          ./system/nixos.nix
          ./system/gnome.nix
          ./system/thinkpad.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/home/toyvo";
              imports = [ 
                ./home/home-common.nix
                ./home/home-linux.nix
                ./home/neovim.nix
                ./home/alacritty.nix
                ./home/kitty.nix
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

      rpi4b8a = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./system/common.nix
          ./system/rpi4b8a.nix
          ./system/nixos.nix
          nixos-hardware.nixosModules.raspberry-pi-4
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.toyvo = {
              home.username = "toyvo";
              home.homeDirectory = "/home/toyvo";
              imports = [ 
                ./home/home-common.nix
                ./home/neovim.nix
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

    homeConfigurations = {
      "deck" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ 
          ({...}:{
            home.username = "deck";
            home.homeDirectory = "/home/deck";
          })
          ./home/home-common.nix
          ./home/home-linux.nix
          ./home/neovim.nix
          ./home/alacritty.nix
          ./home/kitty.nix
          ./home/git.nix
          ./home/gpg-common.nix
          ./home/gpg-linux.nix
          ./home/ssh.nix
          ./home/starship.nix
          ./home/zsh.nix
        ];
      };
    };
  };
}
