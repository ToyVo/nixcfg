{ ... }: {
  services.caddy.virtualHosts = {
    "adguard.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.1:3000
      '';
    };
    "canon.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy https://10.1.0.4:443
      '';
    };
    "nextcloud.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy https://10.1.0.3:12000
      '';
    };
    "octoprint.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.7:5000
      '';
    };
    "omada.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.2:80
      '';
    };
    "portal.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.3:8787
      '';
    };
    "ollama.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.3:11434
      '';
    };
  };
}