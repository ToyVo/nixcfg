# map of hostname to services or other information for said hostname
{
  router = {
    ip = "10.1.0.1";
    # Ethernet
    mac = "7c:2b:e1:13:0e:1d";
    # other ethernet ports
    # mac = "7c:2b:e1:13:0e:1e";
    # mac = "7c:2b:e1:13:0e:1f";
    # mac = "7c:2b:e1:13:0e:20";
    services.adguard.port = 3000;
  };
  omada = {
    ip = "10.1.0.2";
    # Ethernet
    mac = "10:27:f5:bd:04:97";
    # port not configured through nix
    services.omada.port = 80;
  };
  nas = {
    ip = "10.1.0.3";
    # Ethernet
    mac = "30:9c:23:ad:79:43";
    services = {
      homepage = {
        port = 8082;
        subdomain = "@";
      };
      ollama = {
        port = 11434;
        # TODO: load balance with the mac mini, though this is much slower due to the gpu in the machine
        subdomain = "slollama";
      };
      open-webui = {
        port = 11435;
        subdomain = "chat";
      };
      discord_bot = {
        port = 8080;
        subdomain = "@";
        domain = "toyvo.dev";
      };
      # port not configured through nix
      jellyfin.port = 8096;
      portainer = {
        port = 9443;
        selfSigned = true;
      };
      coder.port = 7080;
      cockpit = {
        port = 9090;
        selfSigned = true;
      };
      deluge.port = 8112;
      immich.port = 2283;
      home-assistant.port = 8123;
      # port not configured through nix
      nextcloud.port = 80;
      bazarr.port = 6767;
      radarr.port = 7878;
      lidarr.port = 8686;
      sonarr.port = 8989;
      prowlarr.port = 9696;
      readarr.port = 8787;
      flaresolverr.port = 8191;
      nix-serve = {
        port = 5000;
        subdomain = "nixcache";
      };
      collabora.port = 9980;
    };
  };
  canon-printer = {
    ip = "10.1.0.4";
    # Wifi
    mac = "c4:ac:59:a6:63:33";
    services.canon-printer = {
      # port not configured through nix
      port = 443;
      selfSigned = true;
    };
  };
  hp-printer = {
    ip = "10.1.0.5";
    # Wifi
    mac = "7c:4d:8f:91:d3:9f";
    services.hp-printer = {
      # port not configured through nix
      port = 443;
      selfSigned = true;
    };
  };
  protectli = {
    ip = "10.1.0.6";
    # Ethernet
    mac = "00:e0:67:2c:15:f0";
    # other ethernet ports
    # mac = "00:e0:67:2c:15:f1";
    # mac = "00:e0:67:2c:15:f2";
    # mac = "00:e0:67:2c:15:f3";
  };
  rpi4b8a = {
    ip = "10.1.0.7";
    # Ethernet
    # mac = "e4:5f:01:ad:81:3b";
    # Wifi
    mac = "e4:5f:01:ad:81:3d";
  };
  rpi4b8b = {
    ip = "10.1.0.8";
    # Ethernet
    # mac = "e4:5f:01:ad:a0:da";
    # Wifi
    mac = "e4:5f:01:ad:a0:db";
  };
  rpi4b8c = {
    ip = "10.1.0.9";
    # Ethernet
    # mac = "e4:5f:01:ad:9f:27";
    # Wifi
    mac = "e4:5f:01:ad:9f:28";
  };
  rpi4b4a = {
    ip = "10.1.0.10";
    # Ethernet
    # mac = "dc:a6:32:09:ce:24";
    # Wifi
    mac = "dc:a6:32:09:ce:25";
  };
  MacMini-M1 = {
    ip = "10.1.0.11";
    # Ethernet
    mac = "4c:20:b8:de:e4:01";
    # Wifi
    # mac = "4c:20:b8:df:d1:5b";
    services.ollama.port = 11434;
  };
  MacMini-Intel = {
    ip = "10.1.0.12";
    # Ethernet
    mac = "14:c2:13:ed:e6:ed";
    # Wifi
    # mac = "f0:18:98:8a:6d:ee";
  };
  windows-desktop = {
    ip = "10.1.0.13";
    # Ethernet
    mac = "70:85:c2:8a:53:5b";
    # Wifi
    # mac = "b4:6b:fc:6c:b5:4c";
  };
  steamdeck-nixos = {
    ip = "10.1.0.14";
    mac = "b4:8c:9d:b9:5d:fb";
  };
  oracle = {
    ip = "164.152.108.113";
  };
}
