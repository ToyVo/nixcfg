{ config, lib, pkgs, self, ... }:
let
  cfg = config.programs.kde.catppuccin;
  catppuccin-kde = (pkgs.catppuccin-kde.override {
    flavour = [ config.catppuccin.flavor ];
    accents = [ config.catppuccin.accent ];
    winDecStyles = [ "classic" ];
  });
in
{
  options.programs.kde.catppuccin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.profiles.defaults.enable && config.profiles.gui.enable && pkgs.stdenv.isLinux;
      description = "Enable Catppuccin KDE theme";
    };
    link = lib.mkEnableOption "Link Catppuccin KDE theme";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      catppuccin-kde
    ];
    home.file = self.lib.getFiles { dirPath = catppuccin-kde; enableLink = cfg.link; };
  };
}