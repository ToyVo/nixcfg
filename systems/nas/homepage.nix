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
      services = [
        {
          widget = {
            type = "adguard";
            url = "https://adguard.diekvoss.net";
            username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
            password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
          };
        }
        {
          widget = {
            type = "jellyfin";
            url = "https://jellyfin.diekvoss.net";
            key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
          };
        }
        {
          widget = {
            type = "portainer";
            url = "https://portainer.diekvoss.net";
            key = "{{HOMEPAGE_VAR_PORTAINER_API_KEY}}";
            env = "2";
          };
        }
        {
          widget = {
            type = "qbittorrent";
            url = "https://qbittorrent.diekvoss.net";
            username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
            password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
          };
        }
        {
          widget = {
            type = "immich";
            url = "https://immich.diekvoss.net";
            key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
            version = "2";
          };
        }
        {
          widget = {
            type = "homeassistant";
            url = "https://home-assistant.diekvoss.net";
            key = "{{HOMEPAGE_VAR_HOMEASSISTANT_API_KEY}}";
          };
        }
        {
          widget = {
            type = "nextcloud";
            url = "https://nextcloud.diekvoss.net";
            username = "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}";
            password = "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}";
          };
        }
        {
          widget = {
            type = "bazarr";
            url = "https://bazarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
          };
        }
        {
          widget = {
            type = "radarr";
            url = "https://radarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
          };
        }
        {
          widget = {
            type = "lidarr";
            url = "https://lidarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_LIDARR_API_KEY}}";
          };
        }
        {
          widget = {
            type = "sonarr";
            url = "https://sonarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
          };
        }
        {
          widget = {
            type = "prowlarr";
            url = "https://prowlarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
          };
        }
        {
          widget = {
            type = "readarr";
            url = "https://readarr.diekvoss.net";
            key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
          };
        }
      ] ++ lib.mapAttrsToList (category: services: { "${category}" = services; }) (
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
              hasWidget = services.${service}.hasWidget or false;
            in
            if hasWidget then
              accInner
            else
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
      ];
    };
  };
}
