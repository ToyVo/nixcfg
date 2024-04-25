{ lib, config, pkgs, ... }:
let
  cfg = config.programs.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        # Sorting by how they appear in vscode
        # .NET Install Tool
        ms-python.black-formatter
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        # vadimcn.vscode-lldb
        # continue.continue
        serayuzgur.crates
        usernamehw.errorlens
        dbaeumer.vscode-eslint
        tamasfe.even-better-toml
        github.copilot
        github.copilot-chat
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
        # Mypy Type Checker
        jnoortheen.nix-ide
        # Polyglot notebooks
        esbenp.prettier-vscode
        ms-python.vscode-pylance
        ms-python.python
        # Python Debugger
        rust-lang.rust-analyzer
        vscodevim.vim
      ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        # Can be moved above when fixed https://github.com/NixOS/nixpkgs/issues/202507 
        # or merged https://github.com/NixOS/nixpkgs/pull/211321
        vadimcn.vscode-lldb 
      ];
      userSettings = {
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.fontFamily" = "'MonaspiceNe Nerd Font'";
        "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "editor.formatOnSaveMode" = "modificationsIfAvailable";
        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "git.autofetch" = true;
        "jupyter.askForKernelRestart" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings"."nixd"."formatting"."command" = [ "nixpkgs-fmt" ];
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
