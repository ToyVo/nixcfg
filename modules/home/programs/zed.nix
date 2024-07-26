{ pkgs, config, lib, ... }: {
  options.programs.zed.enable = lib.mkEnableOption "enable zed";

  config = lib.mkIf config.programs.zed.enable {
    xdg.configFile."zed/settings.json".text = ''
      {
          "theme": "Catppuccin Frappé",
          "ui_font_size": 16,
          "buffer_font_size": 16,
          "format_on_save": "on",
          "autosave": "on_focus_change",
          "auto_update": false,
          "buffer_font_family": "MonaspiceNe NF",
          "formatter": [
              "language_server",
              {
                  "external": {
                      "command": "sed",
                      "arguments": ["-e", "s/ *$//"]
                  }
              }
          ],
          "languages": {
              "JavaScript": {
                  "code_actions_on_format": {
                      "source.fixAll.eslint": true,
                      "source.organizeImports": true
                  }
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
