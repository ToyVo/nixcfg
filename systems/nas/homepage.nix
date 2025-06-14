{ config, lib, ... }:
{
  config = lib.mkIf config.services.homepage-dashboard.enable {
    services.homepage-dashboard = {
      openFirewall = true;
      listenPort = config.homelab.${config.networking.hostName}.services.homepage.port;
      allowedHosts = "nas.internal:8082,diekvoss.net";
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
          Networking = [
            {
              "Adguard Home" = {
                href = "https://adguard.diekvoss.net/";
                description = "Adguard Home, DNS adblocker";
              };
            }
            {
              Omada = {
                href = "https://omada.diekvoss.net/";
                description = "Omada cloud controller UI";
              };
            }
          ];
        }
        {
          Printers = [
            {
              Cannon = {
                href = "https://canon.diekvoss.net/";
                description = "Cannon printer UI";
              };
            }
          ];
        }
        {
          APIs = [
            {
              Ollama = {
                href = "https://ollama.diekvoss.net/";
                description = "Ollama API";
              };
            }
          ];
        }
        {
          AI = [
            {
              "Open WebUI" = {
                href = "https://chat.diekvoss.net/";
                description = "Chat with LLMs";
              };
            }
          ];
        }
        {
          "Servarr" = [
            {
              "Bazarr" = {
                href = "https://bazarr.diekvoss.net/";
                description = "Bazarr, subtitle management";
              };
            }
            {
              "Radarr" = {
                href = "https://radarr.diekvoss.net/";
                description = "Radarr, movie management";
              };
            }
            {
              "Sonarr" = {
                href = "https://sonarr.diekvoss.net/";
                description = "Sonarr, TV show management";
              };
            }
            {
              "Lidarr" = {
                href = "https://lidarr.diekvoss.net/";
                description = "Lidarr, music management";
              };
            }
            {
              "Prowlarr" = {
                href = "https://prowlarr.diekvoss.net/";
                description = "Prowlarr, indexer management";
              };
            }
            {
              "Readarr" = {
                href = "https://readarr.diekvoss.net/";
                description = "Readarr, ebook/audiobook management";
              };
            }
          ];
        }
        {
          "To Sort" = [
            {
              "Jellyfin" = {
                href = "https://jellyfin.diekvoss.net/";
                description = "Jellyfin";
              };
            }
            {
              "Cockpit" = {
                href = "https://cockpit.diekvoss.net/";
                description = "Cockpit";
              };
            }
            {
              "Coder" = {
                href = "https://coder.diekvoss.net/";
                description = "Coder";
              };
            }
            {
              "Portainer" = {
                href = "https://portainer.diekvoss.net/";
                description = "Portainer";
              };
            }
            {
              "Immich" = {
                href = "https://immich.diekvoss.net/";
                description = "Immich";
              };
            }
            {
              "Deluge" = {
                href = "https://deluge.diekvoss.net/";
                description = "Deluge";
              };
            }
            {
              "Home Assistant" = {
                href = "https://home-assistant.diekvoss.net/";
                description = "Home Assistant";
              };
            }
            {
              "Nextcloud" = {
                href = "https://nextcloud.diekvoss.net/";
                description = "Nextcloud";
              };
            }
            {
              "Collabora Server" = {
                href = "https://collabora.diekvoss.net/";
                description = "Nextcloud Office";
              };
            }
            {
              "Minecraft" = {
                href = "https://mc.toyvo.dev";
                description = "Minecraft server";
              };
            }
          ];
        }
        {
          "Published Sites" = [
            {
              "Discord Bot UI" = {
                href = "https://toyvo.dev/";
                description = "Discord Bot";
              };
            }
            {
              "Minecraft modpack definition" = {
                href = "https://packwiz.toyvo.dev/";
                description = "Minecraft modpack definition";
              };
            }
          ];
        }
      ];
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
