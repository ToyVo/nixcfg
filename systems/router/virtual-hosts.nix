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
          reverse_proxy http://router.internal:3000
        '';
      };
      "https://canon.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy https://cannon-printer.internal:443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      "https://omada.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://omada.internal:80
        '';
      };
      "https://homepage.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://nas.internal:3000
        '';
      };
      "https://ollama.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://macmini-m1.internal:11434
        '';
      };
      "https://chat.diekvoss.net:443" = {
        useACMEHost = "diekvoss.net";
        extraConfig = ''
          reverse_proxy http://nas.internal:11435
        '';
      };
      "https://toyvo.dev:443" = {
        useACMEHost = "toyvo.dev";
        extraConfig = ''
          reverse_proxy http://nas.internal:8080
        '';
      };
    };
  };
}
