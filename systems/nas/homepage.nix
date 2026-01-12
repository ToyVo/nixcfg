{
  config,
  lib,
  homelab,
  ...
}:
let
  inherit (config.networking) hostName;
in
{
  config = lib.mkIf config.services.homepage-dashboard.enable {
    sops.secrets."homepage.env" = {};
    services.homepage-dashboard = {
      openFirewall = true;
      listenPort = homelab.${hostName}.services.homepage.port;
      allowedHosts = "nas.internal:8082,diekvoss.net";
      environmentFile = config.sops.secrets."homepage.env".path;
      settings = {
        background = "https://images.unsplash.com/photo-1507936580189-3816b4abf640?q=80&w=2400&auto=format&fit=crop";
        cardBlur = "xs";
      };
      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                }
              ];
            }
          ];
        }
        {
          Social = [
            {
              Lemmy = [
                {
                  abbr = "LM";
                  href = "https://programming.dev/";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  href = "https://youtube.com/";
                }
              ];
            }
          ];
        }
      ];
      # docker = [
      #   {
      #     Podman = [
      #       {
      #         socket = "/var/run/podman/podman.sock";
      #       }
      #     ];
      #   }
      # ];
      services = lib.mapAttrsToList (category: services: { "${category}" = services; }) (
        lib.foldl' (
          acc: hostname:
          let
            services = homelab.${hostname}.services or { };
          in
          lib.foldl' (
            accInner: service:
            let
              displayName = services.${service}.displayName or service;
              subdomain = services.${service}.subdomain or service;
              domain = services.${service}.domain or "diekvoss.net";
              category = services.${service}.category or "TODO";
              description = services.${service}.description or "TODO";
              href = if subdomain == "@" then "https://${domain}" else "https://${subdomain}.${domain}";
            in
            accInner
            // {
              ${category} = (accInner.${category} or [ ]) ++ [
                {
                  "${displayName}" = {
                    inherit href description;
                  };
                }
              ];
            }
          ) acc (lib.attrNames services)
        ) { } (lib.attrNames homelab)
      );
      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
        {
          adguard = {
            url = "http://router.internal:3000";
            username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
            password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
          };
        }
        {
          jellyfin = {
            url = "http://nas.internal:8096";
            key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
          };
        }
        {
          portainer = {
            url = "https://nas.internal:9443";
            key = "{{HOMEPAGE_VAR_PORTAINER_API_KEY}}";
          };
        }
        {
          qbittorrent = {
            url = "http://nas.internal:4080";
            username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
            password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
          };
        }
        {
          immich = {
            url = "http://nas.internal:2283";
            key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
          };
        }
        {
          homeassistant = {
            url = "http://nas.internal:8123";
            key = "{{HOMEPAGE_VAR_HOMEASSISTANT_API_KEY}}";
          };
        }
        {
          nextcloud = {
            url = "https://diekvoss.net";
            username = "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}";
            password = "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}";
          };
        }
        {
          bazarr = {
            url = "http://nas.internal:6767";
            key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
          };
        }
        {
          radarr = {
            url = "http://nas.internal:7878";
            key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
          };
        }
        {
          lidarr = {
            url = "http://nas.internal:8686";
            key = "{{HOMEPAGE_VAR_LIDARR_API_KEY}}";
          };
        }
        {
          sonarr = {
            url = "http://nas.internal:8989";
            key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
          };
        }
        {
          prowlarr = {
            url = "http://nas.internal:9696";
            key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
          };
        }
        {
          readarr = {
            url = "http://nas.internal:8787";
            key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
          };
        }
      ];
    };
  };
}
