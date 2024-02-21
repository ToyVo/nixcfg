{ lib, pkgs, config, ... }: 
let
  cfg = config.userPresets.root;
  homeDirectory = if pkgs.stdenv.isDarwin then "/var/root" else "/root";
in
{
  options.userPresets.root = {
    extraHomeManagerModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };

  config = {
    users.users.root = {
      name = "root";
      home = homeDirectory;
      shell = pkgs.zsh;
    };
    home-manager.users.root = {
      home.username = "root";
      home.homeDirectory = homeDirectory;
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

      imports = [] ++ cfg.extraHomeManagerModules;
    };
  };
}

