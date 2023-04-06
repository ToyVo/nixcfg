{ ... }: {
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";
    font.size = 11;
    theme = "Rosé Pine";
    settings = {
      remember_window_size = "no";
      enable_audio_bell = "no";
      initial_window_width = "120c";
      initial_window_height = "30c";
      window_padding_width = "6";
      background_opacity = "0.9";
    };
    extraConfig = ''
      modify_font cell_height -2
      modify_font baseline 2
      modify_font underline_position 2
    '';
  };
}
