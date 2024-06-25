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
        vadimcn.vscode-lldb
        continue.continue
        serayuzgur.crates
        ms-vscode-remote.remote-containers
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
        ms-vscode-remote.remote-ssh
        humao.rest-client
        rust-lang.rust-analyzer
        vscodevim.vim
      ] ++ lib.optionals (builtins.elem system [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ]) [
        ms-python.python
      ] ++ lib.optionals (builtins.elem system [ "x86_64-linux" ]) [
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
        "editor.lineNumbers" = "relative";
        "diffEditor.ignoreTrimWhitespace" = false;
        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;
        "files.trimTrailingWhitespace" = true;
        "git.autofetch" = true;
        "idf.customExtraPaths" = "${config.home.homeDirectory}/.espressif/tools/xtensa-esp-elf-gdb/14.2_20240403/xtensa-esp-elf-gdb/bin:${config.home.homeDirectory}/.espressif/tools/riscv32-esp-elf-gdb/14.2_20240403/riscv32-esp-elf-gdb/bin:${config.home.homeDirectory}/.espressif/tools/xtensa-esp-elf/esp-13.2.0_20240530/xtensa-esp-elf/bin:${config.home.homeDirectory}/.espressif/tools/riscv32-esp-elf/esp-13.2.0_20240530/riscv32-esp-elf/bin:${config.home.homeDirectory}/.espressif/tools/esp32ulp-elf/2.38_20240113/esp32ulp-elf/bin:${config.home.homeDirectory}/.espressif/tools/openocd-esp32/v0.12.0-esp32-20240318/openocd-esp32/bin:${config.home.homeDirectory}/.espressif/tools/esp-rom-elfs/20240305";
        "idf.customExtraVars" = {
            "OPENOCD_SCRIPTS" = "${config.home.homeDirectory}/.espressif/tools/openocd-esp32/v0.12.0-esp32-20240318/openocd-esp32/share/openocd/scripts";
            "ESP_ROM_ELF_DIR" = "${config.home.homeDirectory}/.espressif/tools/esp-rom-elfs/20240305/";
        };
        "idf.espIdfPath" = "${config.home.homeDirectory}/Clone/esp/master/esp-idf";
        "idf.gitPath" = "git";
        "idf.pythonBinPath" = "${config.home.homeDirectory}/.espressif/python_env/idf5.4_py3.9_env/bin/python";
        "idf.toolsPath" = "${config.home.homeDirectory}/.espressif";
        "jupyter.askForKernelRestart" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings"."nil"."formatting"."command" = [ "nixpkgs-fmt" ];
        "mypy-type-checker.args" = ["--ignore-missing-imports"];
        "notebook.formatOnSave.enabled" = true;
        "notebook.insertFinalNewline" = true;
        "notebook.lineNumbers" = "on";
        "prettier.singleQuote" = true;
        "prettier.tabWidth" = 4;
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.defaultProfile.osx" = "fish";
        "terminal.integrated.scrollback" = 10000;
        "workbench.colorTheme" = "Catppuccin Frappé";
      };
    };
  };
}
