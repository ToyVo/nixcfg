{ config, lib, pkgs, system, ... }:
let
  cfg = config.programs.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      package = if pkgs.stdenv.isDarwin then pkgs.vscode else pkgs.vscode-fhs;
      extensions = with pkgs.vscode-extensions; [
        # Sorting by how they appear in vscode
        # .NET Install Tool
        ms-python.black-formatter
        # ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        ms-vscode.cmake-tools
        ms-vscode-remote.remote-ssh
        vadimcn.vscode-lldb
        ms-vscode-remote.remote-containers
        continue.continue
        serayuzgur.crates
        usernamehw.errorlens
        dbaeumer.vscode-eslint
        tamasfe.even-better-toml
        # Github issue notebooks
        eamodio.gitlens
        ms-python.isort
        firsttris.vscode-jest-runner
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        # Jupyter PowerToys
        ms-toolsai.vscode-jupyter-slideshow
        ms-vscode.live-server
        ms-vscode.makefile-tools
        # Mypy Type Checker
        jnoortheen.nix-ide
        # Polyglot notebooks
        esbenp.prettier-vscode
        ms-python.vscode-pylance
        # ms-python.python
        ms-python.debugpy
        rust-lang.rust-analyzer
        vscodevim.vim
      ] ++ lib.optionals (builtins.elem system [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ]) [
        ms-python.python
      ] ++ lib.optionals (builtins.elem system [ "aarch64-linux" "x86_64-linux" ]) [
        ms-vscode.cpptools
      ];
      userSettings = {
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.fontFamily" = "'MonaspiceNe Nerd Font'";
        "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "editor.formatOnSaveMode" = "modificationsIfAvailable";
        "diffEditor.ignoreTrimWhitespace" = false;
        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "git.autofetch" = true;
        "jupyter.askForKernelRestart" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings"."nil"."formatting"."command" = [ "nixpkgs-fmt" ];
        "notebook.formatOnSave.enabled" = true;
        "notebook.insertFinalNewline" = true;
        "notebook.lineNumbers" = "on";
        "prettier.singleQuote" = true;
        "prettier.tabWidth" = 4;
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.defaultProfile.osx" = "fish";
        "workbench.colorTheme" = "Catppuccin Frappé";
      };
    };
  };
}
