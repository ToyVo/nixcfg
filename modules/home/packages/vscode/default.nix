{ lib, config, pkgs, ... }:
let
  cfg = config.cd;
in
{
  options.cd.packages.vscode.enable = lib.mkEnableOption "Enable vscode";

  config = lib.mkIf cfg.packages.vscode.enable {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        jdinhlife.gruvbox
        usernamehw.errorlens
        eamodio.gitlens
        serayuzgur.crates
        github.copilot
        # Can be added to the above when merged https://github.com/NixOS/nixpkgs/pull/211321
        # vadimcn.vscode-lldb
      ];
      userSettings = {
        "workbench.colorTheme" = "Gruvbox Dark Medium";
        "editor.formatOnSave" = true;
        "editor.formatOnSaveMode" = "modificationsIfAvailable";
        "files.autoSave" = "onFocusChange";
        "prettier.tabWidth" = 4;
        "prettier.singleQuote" = true;
        "editor.fontSize" = 14;
        "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
        "editor.fontFamily" = "'MonaspiceNe Nerd Font'";
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "git.autofetch" = true;
      };
    };
  };
}
