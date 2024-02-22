{ ... }: {
  services.caddy.virtualHosts = {
    "https://adguard.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.1:3000
      '';
    };
    "https://canon.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy https://10.1.0.4:443
      '';
    };
    "https://nextcloud.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.3:8080
      '';
    };
    "https://octoprint.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.7:5000
      '';
    };
    "https://omada.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.2:80
      '';
    };
    "https://portal.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.3:8787
      '';
    };
    "https://ollama.diekvoss.net:443" = {
      useACMEHost = "diekvoss.net";
      extraConfig = ''
        reverse_proxy http://10.1.0.3:11434
      '';
    };
  };
}