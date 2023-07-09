{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.cdcfg.users.toyvo;
in
{
  options.cdcfg.users.toyvo = {
    enable = mkEnableOption "toyvo user";
    name = mkOption {
      type = types.str;
      default = "toyvo";
    };
    extraHomeManagerModules = mkOption {
      type = types.listOf types.raw;
      default = [ ];
    };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config =
    let
      homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${cfg.name}" else "/home/${cfg.name}";
      key = lib.fileContents ../keys/ssh_yubikey.pub;
    in
    mkIf cfg.enable {
      users.users.${cfg.name} = lib.mkMerge [
        {
          name = cfg.name;
          description = "Collin Diekvoss";
          home = homeDirectory;
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = [ key ];
        }
        (lib.mkIf pkgs.stdenv.isLinux {
          isNormalUser = true;
          extraGroups = [ "networkmanager" "wheel" "toyvo" "share" ];
          initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
        })
      ];
      home-manager.users.${cfg.name} = {
        home.username = cfg.name;
        home.homeDirectory = homeDirectory;
        home.stateVersion = "23.05";
        home.sessionVariables = {
          GPG_TTY = "$(tty)";
          SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
          MANPAGER = "sh -c 'col -bx | bat -l man -p'";
          EDITOR = "nvim";
        };
        home.sessionPath = [ "$HOME/.local/bin" "$HOME/.cargo/bin" "/opt/homebrew/bin" ];
        home.shellAliases = {
          cat = "bat -pp";
          tree = "exa --tree";
          gpg-scan-card = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
        };
        home.file.".hushlogin".text = "";
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
        xdg.configFile."zellij/layouts/default.kdl".text = ''
          layout {
              pane size=1 borderless=true {
                  plugin location="zellij:tab-bar"
              }
              pane borderless=true
              pane size=2 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }
        '';
        programs.wezterm.enable = true;
        programs.wezterm.extraConfig = lib.fileContents ./wezterm.lua;
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        manual.manpages.enable = false;
        home.packages = with pkgs; lib.mkMerge [
          [ git-crypt gimp element-desktop ]
          (lib.mkIf stdenv.isLinux [ firefox neovide _1password _1password-gui ])
          (lib.mkIf stdenv.isDarwin [ rectangle utm ])
          (lib.mkIf (system == "x86_64-linux") [ keybase-gui ])
        ];

        services.keybase.enable = pkgs.stdenv.isLinux;
        services.kbfs.enable = pkgs.stdenv.isLinux;

        imports = [
          ./git.nix
          ./gpg.nix
          ./ssh.nix
          ./starship.nix
          ./zsh.nix
        ] ++ cfg.extraHomeManagerModules;
      };
    };
}
