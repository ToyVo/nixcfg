{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.system;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh.enable = true;
      fish.enable = true;
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
        # herdr-core >= 0.1.16 honors `shell = [...]` in herdr-core/config.toml
        # (fish default shell); nixpkgs still ships 0.1.15.
        # TODO: drop once nixpkgs herdr-core reaches 0.1.16.
        herdr-core-0-1-16 = pkgs.herdr-core.overrideAttrs (old: rec {
          version = "0.1.16";
          src = pkgs.fetchFromGitHub {
            owner = "herdrdev";
            repo = "herdr-core";
            tag = "v${version}";
            fetchSubmodules = true;
            hash = "sha256-TIOXZswCum0g3qcDK+RDZb9Y7lUu+bx+Oyja4EtKKh4=";
          };
          cargoHash = "sha256-hMkych62liZ+Oe5huM2drN5/6ckpF8AEHH2dyskcivo=";
          # vendor/ghostty is pinned to the same commit as 0.1.15
          # (1e5cdb865807abc990181efb8ebfa9122955cce2), so its Zig deps are
          # byte-identical: reuse the already-fetched output instead of
          # fetching again (fresh `zig fetch` can't init TLS on Darwin, and
          # the output is platform-independent anyway). Note: this must name
          # the original package's output; `old.zigDeps` here would already
          # point at the new src.
          zigDeps = pkgs.herdr-core.zigDeps;
        });
      in
      {
        inherit shells;
        systemPackages =
          with pkgs;
          shells
          ++ [
            age
            broot
            curl
            curlie
            dig
            doggo
            dotnet-sdk_8
            fd
            gnutar
            gping
            graphviz
            gzip
            helix
            herdr
            herdr-core-0-1-16
            httpie
            jq
            just
            kubectl
            lsof
            netcat
            nix-output-monitor
            nixfmt
            nmap
            nvd
            openssh
            openssl
            rclone
            ripgrep
            ast-grep
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
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            aha
            clinfo
            fwupd
            kexec-tools
            mesa-demos
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
