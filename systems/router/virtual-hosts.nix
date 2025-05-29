{ config, lib, ... }:
{
  config = lib.mkIf config.services.nginx.enable {
    users.users.nginx.extraGroups = [ "acme" ];
    services.nginx = {
      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      proxyTimeout = "36000s";

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';

      virtualHosts = let
        base = locations: {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          inherit locations;
        };
        proxy = destination: base {
          "/" = {
            proxyPass = destination;
            extraConfig = lib.mkIf (lib.strings.hasPrefix "https" destination) "proxy_ssl_verify off";
          };
        };
      in {
        "https://adguard.diekvoss.net:443" = proxy "http://10.1.0.1:3000/";
        "https://canon.diekvoss.net:443" = proxy "https://10.1.0.4:443/";
        "https://omada.diekvoss.net:443" = proxy "http://10.1.0.2:80/";
        "https://diekvoss.net:443" = proxy "http://10.1.0.3:8082/";
        "https://ollama.diekvoss.net:443" = proxy "http://10.1.0.11:11434/";
        "https://chat.diekvoss.net:443" = proxy "http://10.1.0.3:11435/";
        "https://toyvo.dev:443" = proxy "http://10.1.0.3:8080/" // {
          useACMEHost = lib.mkForce "toyvo.dev";
        };
        "https://jellyfin.diekvoss.net:443" = proxy "http://10.1.0.3:8096/";
        "https://portainer.diekvoss.net:443" = proxy "https://10.1.0.3:9443/";
        "https://coder.diekvoss.net:443" = proxy "http://10.1.0.3:7080/";
        "https://cockpit.diekvoss.net:443" = proxy "https://10.1.0.3:9090/";
        "https://deluge.diekvoss.net:443" = proxy "http://10.1.0.3:8112/";
        "https://immich.diekvoss.net:443" = proxy "http://10.1.0.3:2283/";
        "https://home-assistant.diekvoss.net:443" = proxy "http://10.1.0.3:8123/";
        "https://nextcloud.diekvoss.net:443" = proxy "http://10.1.0.3:80/";
        "https://collabora.diekvoss.net:443" = base {
          # static files
          "^~ /browser" = {
            proxyPass = "http://10.1.0.3:9980/";
          };

          # WOPI discovery URL
          "^~ /hosting/discovery" = {
            proxyPass = "http://10.1.0.3:9980/";
          };

          # Capabilities
          "^~ /hosting/capabilities" = {
            proxyPass = "http://10.1.0.3:9980/";
          };

          # main websocket
          "~ ^/cool/(.*)/ws$" = {
            proxyPass = "http://10.1.0.3:9980/";
            proxyWebsockets = true;
          };

          # download, presentation and image upload
          "~ ^/(c|l)ool" = {
            proxyPass = "http://10.1.0.3:9980/";
          };

          # Admin Console websocket
          "^~ /cool/adminws" = {
            proxyPass = "http://10.1.0.3:9980/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
