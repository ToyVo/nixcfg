{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.users.agent;
in
{
  # `config.ids.*` is read under `isLinux` guards only. nix-darwin has no
  # `ids` option, so this module must NOT import it — NixOS hosts importing
  # this module must also import `inputs.nixcfg.modules.nixos.ids`.
  options.nixcfg.users.agent.enable = lib.mkEnableOption "agent system user";
  options.userPresets.agent.enable = lib.mkEnableOption "agent user preset";

  config = lib.mkMerge [
    # Preset shorthand for the registry-style `userPresets = { agent...; }`
    # blocks (cf. userPresets.root/toyvo). Default-on so an explicit
    # `nixcfg.users.agent.enable = false` still wins; never the reverse.
    { nixcfg.users.agent.enable = lib.mkIf config.userPresets.agent.enable (lib.mkDefault true); }
    (lib.mkIf cfg.enable {
      users.users.agent = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        uid = config.ids.uids.agent;
        home = "/var/lib/agent";
        group = "agent";
        isSystemUser = true;
        shell = lib.mkDefault pkgs.bash;
        description = "AI agent service user";
        subUidRanges = [
          {
            startUid = 200000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 200000;
            count = 65536;
          }
        ];
      };
      users.groups.agent = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        gid = config.ids.gids.agent;
      };
      security = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        sudo.extraConfig = ''
          agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-container *
          agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/journalctl *
          agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl status *
          agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild *
        '';
      };
      home-manager.users.agent = {
        home.username = "agent";
        home.homeDirectory = "/var/lib/agent";
        nixcfg = {
          users.agent.enable = true;
          shells.enable = true;
          session.enable = true;
          sops-home.enable = true;
          gui.enable = false;
        };
      };
      nix.settings.trusted-users = [
        "agent"
      ];
    })
  ];
}
