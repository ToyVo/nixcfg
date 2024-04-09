{ pkgs, lib, config, ... }: {
  config = lib.mkIf (config.profiles.defaults.enable && config.profiles.gui.enable && pkgs.stdenv.isLinux) {
    home.packages = with pkgs; [
      (catppuccin-kde.override {
        flavour = [ config.catppuccin.flavour ];
        accents = [ config.catppuccin.accent ];
        winDecStyles = [ "classic" ];
      })
    ];
  };
}