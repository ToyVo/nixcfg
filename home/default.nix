{ pkgs, lib, inputs, system, config, ... }:
let
  mkalias = inputs.mkAlias.outputs.apps.${system}.default.program;
in
lib.mkMerge [
  {
    home.stateVersion = "22.11";
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
    home.shellAliases = {
      cat = "bat -pp";
      tree = "exa --tree";
      gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
    };
    home.packages = with pkgs; [
      git-crypt
      ripgrep
      fd
      rustup
    ];
    xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
    xdg.configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';
    programs.home-manager.enable = true;
    programs.bat.enable = true;
    programs.bat.config.theme = "gruvbox-dark";
    programs.exa.enable = true;
    programs.exa.enableAliases = true;
    programs.zellij.enable = true;
    programs.wezterm.enable = true;
    programs.wezterm.extraConfig = lib.fileContents ./wezterm.lua;
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    services.keybase.enable = true;
    services.kbfs.enable = true;
    home.packages = with pkgs; [
      neovide
      firefox
      keybase-gui
      _1password
      _1password-gui
      # yubico-authenticator
    ];
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".hushlogin".text = "";
    home.sessionPath = [
      "/opt/homebrew/bin"
    ];
  })
]
