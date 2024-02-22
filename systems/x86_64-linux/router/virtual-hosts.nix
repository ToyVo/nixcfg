{ ... }: {
  services.nginx.virtualHosts = {
    "adguard.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.1.0.1:3000";
        recommendedProxySettings = true;
      };
    };
    "canon.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://10.1.0.4:443";
        recommendedProxySettings = true;
      };
    };
    "nextcloud.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://10.1.0.3:11000";
        recommendedProxySettings = true;
      };
    };
    "octoprint.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.1.0.7:5000";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
      locations."/webcam/" = {
        proxyPass = "http://10.1.0.7:8080";
      };
    };
    "omada.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.1.0.2:80";
        recommendedProxySettings = true;
      };
    };
    "portal.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.1.0.3:8787";
        recommendedProxySettings = true;
      };
    };
    "ollama.diekvoss.net" = {
      useACMEHost = "diekvoss.net";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.1.0.3:11434";
        recommendedProxySettings = true;
      };
    };
  };
}