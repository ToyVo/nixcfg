{ lib, pkgs, ... }: {
  options.services.ollama = {
    enable = lib.mkEnableOption "Enable ollama startup service";
  };

  config = {
    users.groups.ollama = {};
    users.users.ollama = {
      name = "ollama";
      home = "/usr/share/ollama";
      shell = "/bin/false";
      isSystemUser = true;
      group = "ollama";
    };

    systemd.services.ollama = {
      description = "Ollama Service";
      after = [ "network-online.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        User = "ollama";
        Group = "ollama";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
      };
    };
  };
}
