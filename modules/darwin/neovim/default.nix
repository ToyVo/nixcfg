{ inputs, ... }: {
  imports = [
    inputs.nixvim.nixDarwinModules.nixvim
    ../../nixos/neovim/common.nix
  ];
}

