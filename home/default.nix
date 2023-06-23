{ pkgs, lib, ... }:
lib.mkMerge [
  {
    home.stateVersion = "23.05";
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
    home.packages = with pkgs; [
      git-crypt
      gimp
      element-desktop
      trunk
      rustup
      rustup-toolchain-install-master
    ];
    xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
    xdg.configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';
    programs.home-manager.enable = true;
    programs.bat.enable = true;
    programs.bat.themes = {
      everforest-dark = builtins.readFile (pkgs.fetchFromGitHub
        {
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
    programs.zellij.enableZshIntegration = true;
    programs.zellij.settings = {
      themes = {
        everforest-dark = {
          bg = "#2b3339";
          fg = "#d3c6aa";
          black = "#4b565c";
          red = "#e67e80";
          green = "#a7c080";
          yellow = "#dbbc7f";
          blue = "#7fbbb3";
          magenta = "#d699b6";
          cyan = "#83c092";
          white = "#d3c6aa";
          orange = "#FF9E64";
        };
      };

      theme = "everforest-dark";
    };
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
  (lib.mkIf (pkgs.system == "x86_64-linux") {
    home.packages = with pkgs; [
      keybase-gui
    ];
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    manual.manpages.enable = false;
    home.file.".hushlogin".text = "";
    home.sessionPath = [ "/opt/homebrew/bin" ];
    home.packages = with pkgs; [ rectangle ];
  })
]
