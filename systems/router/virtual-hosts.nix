{ ... }:
{
  services.caddy = {
    globalConfig = ''
      debug
    '';
    logFormat = ''
      level DEBUG
    '';
    virtualHosts = {
      "https://adguard.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.1:3000
        '';
      };
      "https://canon.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy https://10.1.0.4:443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      "https://omada.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.2:80
        '';
      };
      "https://diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:8082
        '';
      };
      "https://ollama.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.11:11434
        '';
      };
      "https://chat.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:11435
        '';
      };
      "https://toyvo.dev:443" = {
        useACMEHost = "toyvo.dev";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:8080
        '';
      };
      "https://jellyfin.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:8096
        '';
      };
      "https://portainer.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy https://10.1.0.3:9443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      "https://coder.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:7080
        '';
      };
      "https://cockpit.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy https://10.1.0.3:9090 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      "https://deluge.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:8112
        '';
      };
      "https://immich.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:2283
        '';
      };
      "https://home-assistant.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://10.1.0.3:8123
        '';
      };
      "https://nextcloud.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy https://10.1.0.3:443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
    };
  };
}
