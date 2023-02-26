{...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions.columns = 120;
      window.dimensions.lines = 30;
      window.padding.x = 8;
      window.padding.y = 8;
      window.opacity = 0.9;
      font.normal.family = "FiraCode Nerd Font";
      font.size = 11;
    };
  };
}
