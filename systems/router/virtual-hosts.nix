{ config, lib, ... }:
{
  config = lib.mkIf config.services.nginx.enable {
    users.users.nginx.extraGroups = [ "acme" ];
    services.nginx = {
      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedBrotliSettings = true;
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

      virtualHosts =
        lib.recursiveUpdate
          (lib.concatMapAttrs (
            hostname:
            {
              ip,
              services ? { },
              ...
            }:
            (lib.mapAttrs' (
              service:
              {
                port,
                subdomain ? service,
                domain ? "diekvoss.net",
                selfSigned ? false,
                ...
              }:
              {
                name = if subdomain == "@" then domain else "${subdomain}.${domain}";
                value = {
                  useACMEHost = domain;
                  forceSSL = true;
                  locations."/" = {
                    proxyPass = "http${if selfSigned then "s" else ""}://${ip}:${toString port}";
                    proxyWebsockets = true;
                    extraConfig = lib.mkIf selfSigned "proxy_ssl_verify off;";
                  };
                };
              }
            ) services)
          ) config.homelab)
          {
            "collabora.diekvoss.net".locations = {
              # static files
              "^~ /browser" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
              };

              # WOPI discovery URL
              "^~ /hosting/discovery" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
              };

              # Capabilities
              "^~ /hosting/capabilities" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
              };

              # main websocket
              "~ ^/cool/(.*)/ws$" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
                proxyWebsockets = true;
              };

              # download, presentation and image upload
              "~ ^/(c|l)ool" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
              };

              # Admin Console websocket
              "^~ /cool/adminws" = {
                proxyPass = "http://${config.homelab.nas.ip}:${toString config.homelab.nas.services.collabora.port}";
                proxyWebsockets = true;
              };
            };
          };
    };
  };
}
