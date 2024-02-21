{ lib, pkgs, config, ... }:
let
  cfg = config.userPresets;
  homePath = if pkgs.stdenv.isDarwin then 
    "/Users" else 
    "/home";
  rootHomeDirectory = if pkgs.stdenv.isDarwin then 
    "/var/root" else 
    "/root";
  enableGui = config.profiles.gui.enable;
in
{
  options.userPresets.toyvo = {
    enable = lib.mkEnableOption "toyvo user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "toyvo";
    };
  };

  config = {
    users.users = {
      ${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
        name = cfg.toyvo.name;
        description = "Collin Diekvoss";
        home = "${homePath}/${cfg.toyvo.name}";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          (lib.fileContents ../../../secrets/ykA_ed25519_sk.pub)
          (lib.fileContents ../../../secrets/ykC_ed25519_sk.pub)
        ];
      };
      root = {
        name = "root";
        home = rootHomeDirectory;
        shell = pkgs.zsh;
      };
    };
    home-manager.users = {
      ${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
        home.username = cfg.toyvo.name;
        home.homeDirectory = "${homePath}/${cfg.toyvo.name}";
        profiles.toyvo.enable = true;
        profiles.gui.enable = enableGui;
      };
      root = {
        home.username = "root";
        home.homeDirectory = rootHomeDirectory;
        home.stateVersion = "24.05";
        xdg.configFile."nix/nix.conf".text = ''
          experimental-features = nix-command flakes
        '';
        xdg.configFile."nixpkgs/config.nix".text = ''
          { allowUnfree = true; }
        '';
        programs.home-manager.enable = true;
        programs.starship.enable = true;
        programs.bash.enable = true;
        programs.zsh.enable = true;
      };
    };
  };
}
