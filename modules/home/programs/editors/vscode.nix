{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.programs.vscode;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      package = if pkgs.stdenv.isDarwin then pkgs.vscode else pkgs.vscode-fhs;
      profiles.default = {
        extensions =
          with pkgs.vscode-extensions;
          [
            # Sorting by how they appear in vscode
            # .NET Install Tool
            ms-python.black-formatter
            # ms-vscode.cpptools
            ms-vscode.cpptools-extension-pack
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
            ms-vscode.cmake-tools
            # vadimcn.vscode-lldb
            continue.continue
            fill-labs.dependi
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
          ]
          ++
            lib.optionals
              (builtins.elem system [
                "aarch64-darwin"
                "x86_64-darwin"
                "x86_64-linux"
              ])
              [
                ms-python.python
              ]
          ++ lib.optionals (builtins.elem system [ "x86_64-linux" ]) [
            ms-vscode.cpptools
          ];
      };
    };

    home.file."${if pkgs.stdenv.hostPlatform.isDarwin then
              "Library/Application Support"
            else
              config.xdg.configHome}/Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcfg/modules/home/programs/editors/vscode-settings.json";
  };
}
