{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.programs.rio;
in
{
  config = lib.mkIf cfg.enable {
    programs.rio = {
      settings = {
        window = {
          width = 1200;
          height = 800;
        };
        shell = {
          program = "${pkgs.nushell}/bin/nu";
          args = [];
        };
      } // lib.importTOML "${inputs.catppuccin-rio}/catppuccin-${config.catppuccin.flavour}.toml";
      # when the PR for adding rio to catppuccin nix is merged https://github.com/catppuccin/nix/pull/100,
      # we can remove the line above, uncomment the line below, and remove catppuccin-rio from flake.nix
      # catppuccin = {
      #   enable = true;
      #   flavour = config.catppuccin.flavour;
      # };
    };
  };
}
