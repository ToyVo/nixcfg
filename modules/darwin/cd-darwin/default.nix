{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.cd;
in
{
  imports = [ ../../nixos/cd-nixos/common.nix ];

  config = lib.mkIf cfg.defaults.enable {
    services.nix-daemon.enable = true;
    security.pam.enableSudoTouchIdAuth = true;
    fonts.fontDir.enable = true;
    fonts.fonts = with pkgs; [ monaspace (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; }) ];
    system = {
      stateVersion = 4;
      keyboard.enableKeyMapping = true;
      keyboard.remapCapsLockToControl = true;
    };
    environment.systemPackages = with pkgs; [
      rectangle
      utm
      wezterm
      pinentry_mac
    ];
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        interactiveShellInit = ''
          [ -n "$PS1" ] && source ${pkgs.blesh}/share/blesh/ble.sh
        '';
      };
    };
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
      };
    };
    homebrew.casks = [
      # nix package not available on darwin
      { name = "firefox"; greedy = true; }
      { name = "thunderbird"; greedy = true; }
      { name = "protonmail-bridge"; greedy = true; }
      { name = "jetbrains-toolbox"; greedy = true; }
      { name = "bruno"; greedy = true; }
      { name = "onlyoffice"; greedy = true; }
      { name = "keybase"; greedy = true; }
      { name = "grammarly"; greedy = true; }
      { name = "rio"; greedy = true; }
      { name = "logseq"; greedy = true; }
      # nix package doesn't provide an app bundle
      { name = "neovide"; greedy = true; }
      # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
      { name = "1password"; greedy = true; }
    ];
    homebrew.brews = [
      # required for neovide
      "libuv"
    ];
    home-manager.sharedModules = [
      {
        cd.darwin.aliasHomeApplications = true;
        programs = {
          zsh.profileExtra = ''
            export PATH="$PATH:/opt/homebrew/bin"
          '';
          fish.shellInit = ''
            set PATH $PATH /opt/homebrew/bin
          '';
          nushell.envFile.text = ''
            $env.PATH = ($env.PATH | append '/opt/homebrew/bin')
          '';
        };
      }
    ];
    cd.darwin.aliasSystemApplications = true;
    cd.packages.gui.enable = true;
  };
}
