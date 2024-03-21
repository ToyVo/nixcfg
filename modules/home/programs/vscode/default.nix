{ lib, config, pkgs, system, ... }:
let
  cfg = config.programs.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        serayuzgur.crates
        usernamehw.errorlens
        dbaeumer.vscode-eslint
        tamasfe.even-better-toml
        github.copilot
        github.copilot-chat
        eamodio.gitlens
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        vscodevim.vim
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter-slideshow
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.jupyter-renderers
        ms-toolsai.jupyter-keymap
      ] ++ lib.optionals (system != "aarch64-darwin") [
        # Can be moved above when fixed https://github.com/NixOS/nixpkgs/issues/202507 
        # or merged https://github.com/NixOS/nixpkgs/pull/211321
        vadimcn.vscode-lldb 
      ];
      userSettings = {
        "CodeGPT.Autocomplete.provider" = "Ollama - deepseek-coder:base";
        "CodeGPT.apiKey" = "Ollama";
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.fontFamily" = "'MonaspiceNe Nerd Font'";
        "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "editor.formatOnSaveMode" = "modificationsIfAvailable";
        "files.autoSave" = "onFocusChange";
        "git.autofetch" = true;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings"."nixd"."formatting"."command" = [ "nixpkgs-fmt" ];
        "prettier.singleQuote" = true;
        "prettier.tabWidth" = 4;
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.defaultProfile.osx" = "fish";
        "workbench.colorTheme" = "Catppuccin Frappé";
        "jupyter.askForKernelRestart" = false;
      };
    };
  };
}
