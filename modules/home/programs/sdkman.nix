{config, pkgs, ...}: {
  home.sessionVariables = {
    SDKMAN_DIR = "${config.home.homeDirectory}/.sdkman";
  };
  programs.bash.initExtra = ''
    [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]] && source $SDKMAN_DIR/bin/sdkman-init.sh
  '';
  programs.zsh.initExtra = ''
    [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]] && source $SDKMAN_DIR/bin/sdkman-init.sh
  '';
  programs.fish.plugins = with pkgs.fishPlugins; [
    {
      name = "sdkman-for-fish";
      src = sdkman-for-fish.src;
    }
  ];
}
