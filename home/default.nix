{ pkgs, lib, ... }:
lib.mkMerge [
  {
    home.stateVersion = "22.11";
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
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
      cargo
      rustfmt
    ];
    xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
    xdg.configFile."nix/nix.conf".text = '' experimental-features = nix-command flakes '';
    programs.home-manager.enable = true;
    programs.bat.enable = true;
    programs.exa.enable = true;
    programs.exa.enableAliases = true;
    programs.zellij.enable = true;
    programs.wezterm.enable = true;
    programs.wezterm.extraConfig = lib.fileContents ./wezterm.lua;
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      neovide
      firefox
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
