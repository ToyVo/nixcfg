{ pkgs, config, lib, inputs, system, ... }:
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
      pinentry_mac
      warp-terminal
      appcleaner
    ] ++ lib.optionals (system == "aarch64-darwin") [
      neovide
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
        # Nix package doesn't exist
        { name = "arc"; greedy = true; }
        { name = "grammarly"; greedy = true; }
        { name = "proton-drive"; greedy = true; }
        # Nix package exists but unavailable on darwin
        { name = "protonvpn"; greedy = true; }
        { name = "proton-mail"; greedy = true; }
        { name = "firefox"; greedy = true; }
        { name = "jetbrains-toolbox"; greedy = true; }
        { name = "bruno"; greedy = true; }
        { name = "onlyoffice"; greedy = true; }
        { name = "keybase"; greedy = true; }
        { name = "logseq"; greedy = true; }
        { name = "lm-studio"; greedy = true; }
      ];
    };
    home-manager.sharedModules = [
      {
        targets.darwin.aliasHomeApplications = true;
      }
    ];
    profiles.gui.enable = true;
  };
}
