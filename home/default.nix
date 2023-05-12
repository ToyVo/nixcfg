{ pkgs, lib, ... }:
lib.mkMerge [
  {
    home.stateVersion = "22.11";
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
    home.sessionPath = [ "$HOME/.local/bin" "$HOME/.cargo/bin" ];
    home.shellAliases = {
      cat = "bat -pp";
      tree = "exa --tree";
      gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
    };
    home.packages = with pkgs; [ git-crypt ripgrep fd rustup gimp ];
    xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
    xdg.configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';
    programs.home-manager.enable = true;
    programs.bat.enable = true;
    programs.bat.themes = {
      everforest-dark = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "mhanberg";
        repo = "everforest-textmate";
        rev = "aa1850676e2c2908e7c5cf5ea7863b130fd65016";
        sha256 = "1rr2b08k95812nchr0c7a9s4qwlawykrh96zdfn55y6k7x5b2rz0";
      } + "/Everforest Dark/Everforest Dark.tmTheme");
    };
    programs.bat.config.theme = "everforest-dark";
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
      firefox
      neovide
      keybase-gui
      _1password
      _1password-gui
    ];
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".hushlogin".text = "";
    home.sessionPath = [ "/opt/homebrew/bin" ];
    home.packages = with pkgs; [ rectangle ];
  })
]
