{ pkgs, lib, config, system, ... }:
let 
  cfg = config.profiles;
in 
{
  options.profiles = {
    defaults.enable = lib.mkEnableOption "Enable toyvo profile";
    gui.enable = lib.mkEnableOption "Enable GUI applications";
  };

  config = lib.mkIf cfg.defaults.enable {
    home = {
      stateVersion = "24.05";
      sessionPath = [] ++ lib.optionals config.programs.volta.enable [
        "${config.programs.volta.voltaHome}/bin"
      ] ++ [
        "${config.home.homeDirectory}/.local/bin"
        "${config.home.homeDirectory}/.bin"
        "${config.home.homeDirectory}/bin"
        "/run/wrappers/bin"
        "${config.home.homeDirectory}/.nix-profile/bin"
        "/nix/profile/bin"
        "${config.home.homeDirectory}/.local/state/nix/profile/bin"
        "/etc/profiles/per-user/${config.home.username}/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
      ] ++ lib.optionals (system == "aarch64-darwin") [
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        "/System/Cryptexes/App/usr/bin"
      ] ++ 
      # TODO: should only be set if not nixos
      [
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/bin"
        "/usr/sbin"
        "/bin"
        "/sbin"
        "/usr/local/games"
        "/usr/games"
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
        "/Library/Apple/usr/bin"
      ];
    };
    xdg.configFile = {
      "nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
      "nixpkgs/config.nix".text = ''
        { allowUnfree = true; }
      '';
    };
    programs = {
      home-manager.enable = true;
      starship = {
        enable = true;
        settings = {
          right_format = "$time";
          time.disabled = false;
        };
      };
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
      zsh.enable = true;
      bash.enable = true;
      fish.enable = true;
      nushell.enable = true;
      powershell.enable = true;
    };
    services.easyeffects = lib.mkIf (pkgs.stdenv.isLinux && cfg.gui.enable) {
      enable = true;
    };
  };
}

