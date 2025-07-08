{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.minecraft-server;
  mshConfig = {
    Server = {
      Folder = cfg.dataDir;
      # cfg.package will be linked to cfg.dataDir/minecraft-server
      FileName = "minecraft-server";
      # Version = "1.19.2";
      # Protocol = 760;
    };
    Commands = {
      StartServer = "${lib.getExe cfg.package} ${cfg.jvmOpts}";
      # StartServerParam = "-Xmx1024M -Xms1024M";
      StopServer = "stop";
      StopServerAllowKill = 10;
    };
    Msh = {
      Debug = 2;
      ID = "";
      MshPort = 25565;
      MshPortQuery = 25565;
      EnableQuery = true;
      TimeBeforeStoppingEmptyServer = 30;
      SuspendAllow = false;
      SuspendRefresh = -1;
      InfoHibernation = "                   §fserver status:\n                   §b§lHIBERNATING";
      InfoStarting = "                   §fserver status:\n                    §6§lWARMING UP";
      NotifyUpdate = true;
      NotifyMessage = true;
      Whitelist = [ ];
      WhitelistImport = false;
      ShowResourceUsage = false;
      ShowInternetUsage = false;
    };
  };
in
{
  options.services.minecraft-server = {
    enableHibernation = lib.mkEnableOption "Use minecraft-server-hibernation as a proxy to save resources";
    frozenIcon = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The icon to use when the server is frozen.";
    };
    runningIcon = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The icon to use when the server is running.";
    };
  };

  config = lib.mkIf (cfg.enableHibernation && cfg.enable) {
    networking.firewall = {
      allowedTCPPorts = [
        mshConfig.Msh.MshPort
      ];
      allowedUDPPorts = [
        mshConfig.Msh.MshPort
        mshConfig.Msh.MshPortQuery
      ];
    };
    services.minecraft-server = {
      eula = true;
      declarative = true;
      serverProperties = {
        server-port = 25566;
        "query.port" = 25566;
        difficulty = 3;
        enable-query = true;
        allow-flight = true;
        spawn-protection = 0;
        max-world-size = 50000;
      };
    };
    systemd.services.minecraft-server = {
      path = [ pkgs.jre ];
      serviceConfig = {
        ExecStart = lib.mkForce (lib.getExe pkgs.minecraft-server-hibernation);
        ExecStop = lib.mkForce "";
      };
      preStart = lib.mkAfter (
        ''
          ln -sf "${lib.getExe cfg.package}" "${cfg.dataDir}/${mshConfig.Server.FileName}"
          ln -sf "${(pkgs.writeText "msh-config.json" (builtins.toJSON mshConfig))}" "${cfg.dataDir}/msh-config.json"
        ''
        + lib.optionalString (cfg.runningIcon != null) ''
          ln -sf "${cfg.runningIcon}" "${cfg.dataDir}/server-icon.png"
        ''
        + lib.optionalString (cfg.frozenIcon != null) ''
          ln -sf "${cfg.frozenIcon}" "${cfg.dataDir}/server-icon-frozen.png"
        ''
      );
    };
  };
}
