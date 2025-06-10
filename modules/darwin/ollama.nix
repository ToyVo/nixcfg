{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ollama;
in
{

  options = {
    services.ollama = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the Ollama Daemon.";
      };

      package = lib.mkOption {
        type = lib.types.path;
        default = pkgs.ollama;
        description = "This option specifies the ollama package to use.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = ''
          The host address which the ollama server HTTP interface listens to.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 11434;
        description = ''
          Which port the ollama server listens to.
        '';
      };

      models = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          The directory that the ollama service will read models from and download new models to.
        '';
      };

      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          OLLAMA_LLM_LIBRARY = "cpu";
          HIP_VISIBLE_DEVICES = "0,1";
        };
        description = ''
          Set arbitrary environment variables for the ollama service.

          Be aware that these are only seen by the ollama server (launchd daemon),
          not normal invocations like `ollama run`.
          Since `ollama run` is mostly a shell around the ollama server, this is usually sufficient.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    launchd.agents.ollama = {
      path = [ config.environment.systemPath ];
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        ProgramArguments = [
          "${cfg.package}/bin/ollama"
          "serve"
        ];

        EnvironmentVariables =
          cfg.environmentVariables
          // {
            OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          }
          // (lib.optionalAttrs (cfg.models != null) {
            OLLAMA_MODELS = cfg.models;
          });
      };
    };
  };
}
