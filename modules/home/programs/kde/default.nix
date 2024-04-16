{ pkgs, lib, config, ... }: let 
  cfg = config.programs.kde.catppuccin;
  catppuccin-kde = (pkgs.catppuccin-kde.override {
    flavour = cfg.flavour;
    accents = cfg.accents;
    winDecStyles = cfg.winDecStyles;
  });
in {
  options.kde.catppuccin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.profiles.defaults.enable && config.profiles.gui.enable && pkgs.stdenv.isLinux;
      description = "Enable Catppuccin KDE theme";
    };
    flavour = {
      type = lib.types.listOf lib.types.str;
      default = [ config.catppuccin.flavour ];
      description = "Catppuccin KDE theme flavour";
    };
    accents = {
      type = lib.types.listOf lib.types.str;
      default = [ config.catppuccin.accent ];
      description = "Catppuccin KDE theme accent";
    };
    winDecStyles = {
      type = lib.types.listOf lib.types.str;
      default = [ "classic" ];
      description = "Catppuccin KDE theme window decoration styles";
    };
    link = {
      type = lib.types.bool;
      default = false;
      description = "Link Catppuccin KDE theme files to ~/.local/share (for non-NixOS)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      catppuccin-kde
    ];
    home.file = lib.mkIf cfg.link builtins.listToAttrs (
      builtins.concatMap (dir: map (file: {
        name = ".local/${dir}/${file}";
        value = { source = "${catppuccin-kde}/${dir}/${file}"; };
      }) (builtins.listDirectory "${catppuccin-kde}/${dir}"))
      (builtins.listDirectory catppuccin-kde)
    );
  };
}