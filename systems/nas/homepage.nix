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
    services.homepage-dashboard = {
      openFirewall = true;
      listenPort = homelab.${hostName}.services.homepage.port;
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
      ];
    };
  };
}
