{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.programs.zed.enable = lib.mkEnableOption "enable zed";

  config = lib.mkIf config.programs.zed.enable {
    # TODO: see if we can make this file mutable
    xdg.configFile."zed/settings.json".text = ''
      {
          "assistant": {
            "default_model": {
              "provider": "ollama",
              "model": "deepseek-r1:14b"
            },
            "version": "2"
          },
          "theme": "Catppuccin Frappé",
          "ui_font_size": 16,
          "buffer_font_size": 16,
          "format_on_save": "on",
          "autosave": "on_focus_change",
          "auto_update": false,
          "buffer_font_family": "MonaspiceNe Nerd Font",
          "buffer_font_features": {
            "ss01": true,
            "ss02": true,
            "ss03": true,
            "ss04": true,
            "ss05": true,
            "ss06": true,
            "ss07": true,
            "ss08": true,
            "calt": true,
            "dlig": true
          },
          "formatter": [
              {
                  "language_server": {
                      "name": "rust-analyzer"
                  }
              },
              {
                  "external": {
                      "command": "sed",
                      "arguments": ["-e", "s/ *$//"]
                  }
              },
          ],
          "languages": {
              "JavaScript": {
                  "code_actions_on_format": {
                      "source.fixAll.eslint": true,
                      "source.organizeImports": true
                  },
                  "formatter": {
                      "external": {
                          "command": "prettier",
                          "arguments": ["--stdin-filepath", "{buffer_path}"]
                      }
                  },
              }
          },
          "inlay_hints": {
              "enabled": true
          },
          "hour_format": "hour24",
          "vim_mode": true
      }
    '';
  };
}
