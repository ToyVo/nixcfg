{ inputs, ... }: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
    ./common.nix
  ];
}
