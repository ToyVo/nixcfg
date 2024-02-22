{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.profiles.defaults;
in
{
  imports = [ 
    ../../nixos/profiles/common.nix
    inputs.nixvim.nixDarwinModules.nixvim
    ../../nixos/programs/neovim/common.nix
    ../../nixos/users/common.nix 
   ];

  config = lib.mkIf cfg.enable {
    services.nix-daemon.enable = true;
    security.pam.enableSudoTouchIdAuth = true;
    fonts = {
      fontDir.enable = true;
      fonts = with pkgs; [ monaspace (nerdfonts.override { fonts = [ "Monaspace" "NerdFontsSymbolsOnly" ]; }) ];
    };
    system = {
      stateVersion = 4;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      defaults.finder.AliasSystemApplications = true;
    };
    environment.systemPackages = with pkgs; [
      rectangle
      utm
      wezterm
      pinentry_mac
      rio
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
      casks = [
        # nix package not available on darwin
        { name = "arc"; greedy = true; }
        { name = "firefox"; greedy = true; }
        { name = "thunderbird"; greedy = true; }
        { name = "jetbrains-toolbox"; greedy = true; }
        { name = "bruno"; greedy = true; }
        { name = "onlyoffice"; greedy = true; }
        { name = "keybase"; greedy = true; }
        { name = "grammarly"; greedy = true; }
        { name = "logseq"; greedy = true; }
        { name = "lm-studio"; greedy = true; }
        { name = "app-cleaner"; greedy = true; }
        # nix package doesn't provide an app bundle
        { name = "neovide"; greedy = true; }
        # must be installed at /Applications, nix-darwin installs it at /Applications/nix apps
        { name = "1password"; greedy = true; }
      ];
      brews = [
        # required for neovide
        "libuv"
      ];
    };
    home-manager.sharedModules = [
      {
        targets.darwin.aliasHomeApplications = true;
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
    profiles.gui.enable = true;
  };
}

