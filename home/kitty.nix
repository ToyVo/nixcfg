{...}: {
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";
    font.size = 11;
    theme = "Gruvbox Dark";
    settings = {
      remember_window_size = "no";
      enable_audio_bell = "no";
      initial_window_width = "120c";
      initial_window_height = "30c";
      window_padding_width = "6";
      backgroud_opacity = "0.5";
      dynamic_background_opacity = "yes";
    };
  };
}
