{ lib, pkgs, config, ... }: {
  options.services.ollama = {
    enable = lib.mkEnableOption "Enable ollama startup service";
    openFirewall = lib.mkEnableOption "Open firewall" // {
      default = true;
    };
  };

  config = {
    users.groups.ollama = {};
    users.users.ollama = {
      name = "ollama";
      home = "/home/ollama";
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

    networking.firewall.allowedTCPPorts = lib.mkIf config.services.ollama.openFirewall [ 11434 ];
  };
}
