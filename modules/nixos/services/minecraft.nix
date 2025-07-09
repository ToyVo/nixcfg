{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.minecraft-server;

  # We don't allow eula=false anyways
  eulaFile = builtins.toFile "eula.txt" ''
    # eula.txt managed by NixOS Configuration
    eula=true
  '';

  whitelistFile = pkgs.writeText "whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (n: v: {
        name = n;
        uuid = v;
      }) cfg.whitelist
    )
  );

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (
    ''
      # server.properties managed by NixOS configuration
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: v: "${n}=${cfgToString v}") cfg.serverProperties
    )
  );

  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';

  # To be able to open the firewall, we need to read out port values in the
  # server properties, but fall back to the defaults when those don't exist.
  # These defaults are from https://minecraft.wiki/w/Server.properties#Java_Edition
  defaultServerPort = 25565;

  serverPort =
    if cfg.enableHibernation then
      cfg.mshConfig.Msh.MshPort
    else
      cfg.serverProperties.server-port or defaultServerPort;

  rconPort =
    if cfg.serverProperties.enable-rcon or false then
      cfg.serverProperties."rcon.port" or 25575
    else
      null;

  queryPort =
    if cfg.enableHibernation then
      cfg.mshConfig.Msh.MshPortQuery
    else if cfg.serverProperties.enable-query or false then
      cfg.serverProperties."query.port" or 25565
    else
      null;

in
{
  disabledModules = [
    "services/games/minecraft-server.nix"
  ];
  options = {
    services.minecraft-server = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Server. The server
          data will be loaded from and saved to
          {option}`services.minecraft-server.dataDir`.
        '';
      };

      declarative = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to use a declarative Minecraft server configuration.
          Only if set to `true`, the options
          {option}`services.minecraft-server.whitelist` and
          {option}`services.minecraft-server.serverProperties` will be
          applied.
        '';
      };

      eula = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether you agree to [Mojangs EULA](https://www.minecraft.net/eula).
          This option must be set to `true` to run Minecraft server.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/minecraft";
        description = ''
          Directory to store Minecraft database and other state/data files.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for the server.
        '';
      };

      whitelist = lib.mkOption {
        type =
          let
            minecraftUUID =
              lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
              // {
                description = "Minecraft UUID";
              };
          in
          lib.types.attrsOf minecraftUUID;
        default = { };
        description = ''
          Whitelisted players, only has an effect when
          {option}`services.minecraft-server.declarative` is
          `true` and the whitelist is enabled
          via {option}`services.minecraft-server.serverProperties` by
          setting `white-list` to `true`.
          This is a mapping from Minecraft usernames to UUIDs.
          You can use <https://mcuuid.net/> to get a
          Minecraft UUID for a username.
        '';
        example = lib.literalExpression ''
          {
            username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
          };
        '';
      };

      serverProperties = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
        default = { };
        example = lib.literalExpression ''
          {
            server-port = 43000;
            difficulty = 3;
            gamemode = 1;
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "hunter2";
          }
        '';
        description = ''
          Minecraft server properties forthe server.properties file. Only has
          an effect when {option}`services.minecraft-server.declarative`
          is set to `true`. See
          <https://minecraft.wiki/w/Server.properties#Java_Edition>
          for documentation on these values.
        '';
      };

      mshConfig = lib.mkOption {
        type =
          with lib.types;
          attrsOf (
            attrsOf (oneOf [
              bool
              int
              str
              (listOf str)
            ])
          );
        default = { };
        example = lib.literalExpression ''
          {
            Server = {
              Folder = "{path/to/server/folder}";
              FileName = "{server.jar}";
              Version = "1.19.2";
              Protocol = 760;
            };
            Commands = {
              StartServer = "java <Commands.StartServerParam> -jar <Server.FileName> nogui";
              StartServerParam = "-Xmx1024M -Xms1024M";
              StopServer = "stop";
              StopServerAllowKill = 10;
            };
            Msh = {
              Debug = 1;
              ID = "";
              MshPort = 25555;
              MshPortQuery = 25555;
              EnableQuery = true;
              TimeBeforeStoppingEmptyServer = 30;
              SuspendAllow = false;
              SuspendRefresh = -1;
              InfoHibernation = "                   §fserver status:\n                   §b§lHIBERNATING";
              InfoStarting = "                   §fserver status:\n                    §6§lWARMING UP";
              NotifyUpdate = true;
              NotifyMessage = true;
              Whitelist = [];
              WhitelistImport = false;
              ShowResourceUsage = false;
              ShowInternetUsage = false;
            };
          }
        '';
        description = ''
          Minecraft server hibernation configuration file. Only has
          an effect when {option}`services.minecraft-server.declarative`
          is set to `true`. See
          <https://github.com/gekware/minecraft-server-hibernation/tree/v${pkgs.minecraft-server-hibernation.version}?tab=readme-ov-file>
          for documentation on these values.
        '';
      };

      package = lib.mkPackageOption pkgs "minecraft-server" {
        example = "pkgs.minecraft-server_1_12_2";
      };

      jvmOpts = lib.mkOption {
        type = lib.types.separatedString " ";
        default = "-Xmx2048M -Xms2048M";
        # Example options from https://minecraft.wiki/w/Tutorial:Server_startup_script
        example =
          "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
          + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
          + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
        description = "JVM options for the Minecraft server.";
      };

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
  };

  config = lib.mkIf cfg.enable {

    users.users.minecraft = {
      description = "Minecraft server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "minecraft";
    };
    users.groups.minecraft = { };

    systemd.sockets.minecraft-server = lib.mkIf (!cfg.enableHibernation) {
      bindsTo = [ "minecraft-server.service" ];
      socketConfig = {
        ListenFIFO = "/run/minecraft-server.stdin";
        SocketMode = "0660";
        SocketUser = "minecraft";
        SocketGroup = "minecraft";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };

    systemd.services.minecraft-server = {
      path = lib.mkIf cfg.enableHibernation [ pkgs.jre ];
      description = "Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      requires = lib.mkIf (!cfg.enableHibernation) [ "minecraft-server.socket" ];
      after = [
        "network.target"
      ] ++ lib.optionals (!cfg.enableHibernation) [ "minecraft-server.socket" ];

      serviceConfig = {
        ExecStart =
          if cfg.enableHibernation then
            (lib.getExe pkgs.minecraft-server-hibernation)
          else
            "${cfg.package}/bin/minecraft-server ${cfg.jvmOpts}";
        ExecStop = lib.mkIf (!cfg.enableHibernation) "${stopScript} $MAINPID";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = cfg.dataDir;

        StandardInput = lib.mkIf (!cfg.enableHibernation) "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      preStart =
        ''
          ln -sf ${eulaFile} eula.txt
        ''
        + (
          if cfg.declarative then
            ''

              if [ -e .declarative ]; then

                # Was declarative before, no need to back up anything
                ln -sf ${whitelistFile} whitelist.json
                cp -f ${serverPropertiesFile} server.properties

              else

                # Declarative for the first time, backup stateful files
                ln -sb --suffix=.stateful ${whitelistFile} whitelist.json
                cp -b --suffix=.stateful ${serverPropertiesFile} server.properties

                # server.properties must have write permissions, because every time
                # the server starts it first parses the file and then regenerates it..
                chmod +w server.properties
                echo "Autogenerated file that signifies that this server configuration is managed declaratively by NixOS" \
                  > .declarative

              fi
            ''
            + lib.optionalString cfg.enableHibernation ''
              ln -sf "${lib.getExe cfg.package}" "${cfg.dataDir}/${cfg.mshConfig.Server.FileName}"
              ln -sf "${(pkgs.writeText "msh-config.json" (builtins.toJSON cfg.mshConfig))}" "${cfg.dataDir}/msh-config.json"
            ''
            + lib.optionalString (cfg.runningIcon != null) ''
              ln -sf "${cfg.runningIcon}" "${cfg.dataDir}/server-icon.png"
            ''
            + lib.optionalString (cfg.enableHibernation && cfg.frozenIcon != null) ''
              ln -sf "${cfg.frozenIcon}" "${cfg.dataDir}/server-icon-frozen.png"
            ''
          else
            ''
              if [ -e .declarative ]; then
                rm .declarative
              fi
            ''
        );
    };

    networking.firewall = lib.mkIf cfg.openFirewall (
      if cfg.declarative then
        {
          allowedUDPPorts = [ serverPort ];
          allowedTCPPorts =
            [ serverPort ]
            ++ lib.optional (queryPort != null) queryPort
            ++ lib.optional (rconPort != null) rconPort;
        }
      else
        {
          allowedUDPPorts = [ defaultServerPort ];
          allowedTCPPorts = [ defaultServerPort ];
        }
    );

    assertions = [
      {
        assertion = cfg.eula;
        message =
          "You must agree to Mojangs EULA to run minecraft-server."
          + " Read https://account.mojang.com/documents/minecraft_eula and"
          + " set `services.minecraft-server.eula` to `true` if you agree.";
      }
    ];

  };
}
