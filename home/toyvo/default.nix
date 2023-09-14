{ lib, pkgs, config, ... }:
let
  cfg = config.cdcfg.users.toyvo;
in
{
  options.cdcfg.users.toyvo = {
    enable = lib.mkEnableOption "toyvo user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "toyvo";
    };
    extraHomeManagerModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };

  config =
    let
      homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${cfg.name}" else "/home/${cfg.name}";
      key = lib.fileContents ./keys/ssh_yubikey.pub;
    in
    lib.mkIf cfg.enable {
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
          extraGroups = [ "networkmanager" "wheel" ];
          initialHashedPassword = "$y$j9T$tkZ4b5vK1fCsRP0oWUb0e1$w0QbUEv9swXir33ivvM70RYTYflQszeLBi3vubYTqd8";
        })
      ];
      home-manager.users.${cfg.name} = {
        home.username = cfg.name;
        home.homeDirectory = homeDirectory;
        home.stateVersion = "23.05";
        home.sessionVariables = {
          EDITOR = "nvim";
        };
        home.sessionPath = [ "$HOME/.local/bin" ] ++ lib.optionals pkgs.stdenv.isDarwin [ "/opt/homebrew/bin" ];
        xdg.configFile."ideavim/ideavimrc".source = ./ideavimrc;
        xdg.configFile."nix/nix.conf".text = ''
          experimental-features = nix-command flakes
        '';
        programs.home-manager.enable = true;
        programs.starship.enable = true;
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        home.packages = with pkgs; [
          git-crypt
        ];

        home.file = lib.mkIf pkgs.stdenv.isDarwin {
          ".hushlogin".text = "";
        };
        services.keybase.enable = pkgs.stdenv.isLinux;
        services.kbfs.enable = pkgs.stdenv.isLinux;

        imports = [
          ./bat.nix
          ./eza.nix
          ./git.nix
          ./gpg.nix
          ./ssh.nix
          ./wezterm.nix
          ./zellij.nix
          ./zsh.nix
          ./vscode.nix
        ] ++ cfg.extraHomeManagerModules;
      };
    };
}
