{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nvim;
in
{
  options.programs.nvim.enable = lib.mkEnableOption "Enable nixvim";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
      nixfmt-rfc-style
    ];
    programs.nixvim = import ./config {
      pkgs = pkgs;
      catppuccin_flavor = config.catppuccin.flavor;
    } // {
      enable = true;
    };
  };
}
