{ lib, config, pkgs, ... }:
let
  cfg = config.programs.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        # vadimcn.vscode-lldb # Can be uncommented when merged https://github.com/NixOS/nixpkgs/pull/211321
        serayuzgur.crates
        usernamehw.errorlens
        dbaeumer.vscode-eslint
        tamasfe.even-better-toml
        github.copilot
        github.copilot-chat
        eamodio.gitlens
        jdinhlife.gruvbox
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        vscodevim.vim
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
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings"."nixd"."formatting"."command" = [ "nixpkgs-fmt" ];
        "CodeGPT.apiKey" = "Ollama";
        "CodeGPT.Autocomplete.provider" = "Ollama - deepseek-coder:base";
        "terminal.integrated.defaultProfile.osx" = "fish";
        "terminal.integrated.defaultProfile.linux" = "fish";
      };
    };
  };
}
