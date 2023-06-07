inputs:
let
  system = "aarch64-linux";
  user = "toyvo";
in inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ../system/filesystem/sd.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      networking.hostName = "rpi4b8a";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      hardware.raspberry-pi."4".fkms-3d.enable = true;
    })
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/neovim
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    }
  ];
}
