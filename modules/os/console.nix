{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf cfg.defaults.enable {
    programs = {
      zsh.enable = true;
      fish.enable = true;
      nh = {
        enable = true;
        os.flake = "${config.users.users.${config.userPresets.toyvo.name}.home}/nixcfg";
        clean.enable = true;
      };
    };
    environment =
      let
        shells = with pkgs; [
          bashInteractive
          fish
          nushell
          powershell
          zsh
        ];
      in
      {
        inherit shells;
        systemPackages =
          with pkgs;
          shells
          ++ [
            age
            broot
            cachix
            curl
            dig
            dogdns
            dotnet-sdk_8
            fd
            git-crypt
            gnutar
            gping
            graphviz
            gzip
            helix
            jq
            just
            kubectl
            lsof
            netcat
            nix-output-monitor
            nixfmt-rfc-style
            nmap
            nvd
            openssh
            openssl
            rclone
            ripgrep
            rsync
            sops
            sqlite
            tlrc
            unzip
            uutils-coreutils-noprefix
            wget
            xz
            zip
            zstd
          ]
          ++ lib.optionals stdenv.isLinux [
            aha
            clinfo
            fwupd
            glxinfo
            pciutils
            vulkan-tools
            wayland-utils
            yubico-piv-tool
            yubikey-manager
            yubikey-personalization
          ];
      };
  };
}
