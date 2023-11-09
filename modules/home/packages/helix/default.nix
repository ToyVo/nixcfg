{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.helix.enable = lib.mkEnableOption "Enable helix";

  config = lib.mkIf cfg.packages.helix.enable {
    home.packages = with pkgs; [
      nodePackages_latest.bash-language-server
      nodePackages_latest.typescript-language-server
      clang-tools
      vscode-langservers-extracted
      nil
      marksman
      taplo
      yaml-language-server
      lldb
    ];
    programs.helix = {
      enable = true;
      settings = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          bufferline = "always";
        };
      };
    };
  };
}
