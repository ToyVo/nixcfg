{ config, lib, pkgs, system, ... }: {
  imports = [
    ../common
    ./alias-system-apps.nix
    ./podman.nix
  ];
  config = lib.mkIf config.profiles.defaults.enable {
    services.nix-daemon.enable = true;
    security.pam.enableSudoTouchIdAuth = true;
    system = {
      stateVersion = 4;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      defaults.finder.AliasSystemApplications = true;
    };
    programs = {
      bash = {
        enable = true;
        # enableCompletion isn't compatible with uutils-coreutils-noprefix because when both uutils-coreutils-noprefix and
        # bash-completion are installed into systemPackages, there are bash completions that collide.
        # I've taken the text from nixpkgs instead of nix-darwin, they are the same except for the if statement.
        interactiveShellInit = ''
          [ -n "$PS1" ] && source ${pkgs.blesh}/share/blesh/ble.sh

          # Check whether we're running a version of Bash that has support for
          # programmable completion. If we do, enable all modules installed in
          # the system and user profile in obsolete /etc/bash_completion.d/
          # directories. Bash loads completions in all
          # $XDG_DATA_DIRS/bash-completion/completions/
          # on demand, so they do not need to be sourced here.
          if shopt -q progcomp &>/dev/null; then
            . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
            nullglobStatus=$(shopt -p nullglob)
            shopt -s nullglob
            for p in $NIX_PROFILES; do
              for m in "$p/etc/bash_completion.d/"*; do
                . "$m"
              done
            done
            eval "$nullglobStatus"
            unset nullglobStatus p m
          fi
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
        { name = "bruno"; greedy = true; }
        { name = "floorp"; greedy = true; }
        { name = "jetbrains-toolbox"; greedy = true; }
        { name = "logseq"; greedy = true; }
        { name = "onlyoffice"; greedy = true; }
        { name = "podman-desktop"; greedy = true; }
        { name = "proton-mail"; greedy = true; }
        { name = "protonvpn"; greedy = true; }
      ] ++ lib.optionals (system == "aarch64-darwin") [
        { name = "lm-studio"; greedy = true; }
      ];
      taps = [
        "cfergeau/crc"
      ];
      brews = [
        "vfkit"
      ];
    };
    home-manager.sharedModules = [
      ({ config, pkgs, lib, ... }: {
        targets.darwin.aliasHomeApplications = true;
        home = lib.mkIf (config.sops.secrets != { }) {
          activation.sops-nix = lib.mkForce ''
            echo "Skipping..."
          '';
          packages = [
            (pkgs.writeShellScriptBin "sops_user_decrypt" ''
              ${config.launchd.agents.sops-nix.config.Program}
            '')
          ];
        };
      })
    ];
    profiles.gui.enable = true;
  };
}
