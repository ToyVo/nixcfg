{
  kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "br0"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
        lfc-interval = 3600; # 1 hour in seconds
      };
      authoritative = true;
      renew-timer = 3600 * 5;
      rebind-timer = 3600 * 8;
      valid-lifetime = 3600 * 9;
      subnet4 = [
        {
          pools = [
            {
              pool = "10.1.0.64 - 10.1.0.254";
            }
          ];
          subnet = "10.1.0.0/24";
          option-data = [
            {
              name = "routers";
              data = "10.1.0.1";
            }
          ];
          reservations = [
            {
              hostname = "omada";
              ip-address = "10.1.0.2";
              # Ethernet
              hw-address = "10:27:f5:bd:04:97";
            }
            {
              hostname = "nas";
              # if changing ip, change A record on cloudflare
              ip-address = "10.1.0.3";
              # Ethernet
              hw-address = "30:9c:23:ad:79:43";
            }
            {
              hostname = "canon-printer";
              ip-address = "10.1.0.4";
              # Wifi
              hw-address = "c4:ac:59:a6:63:33";
            }
            {
              hostname = "hp-printer";
              ip-address = "10.1.0.5";
              # Wifi
              hw-address = "7c:4d:8f:91:d3:9f";
            }
            {
              hostname = "protectli";
              ip-address = "10.1.0.6";
              # Ethernet
              hw-address = "00:e0:67:2c:15:f0";
              # other ethernet ports
              # hw-address = "00:e0:67:2c:15:f1";
              # hw-address = "00:e0:67:2c:15:f2";
              # hw-address = "00:e0:67:2c:15:f3";
            }
            {
              hostname = "rpi4b8a";
              ip-address = "10.1.0.7";
              # Ethernet
              # hw-address = "e4:5f:01:ad:81:3b";
              # Wifi
              hw-address = "e4:5f:01:ad:81:3d";
            }
            {
              hostname = "rpi4b8b";
              ip-address = "10.1.0.8";
              # Ethernet
              # hw-address = "e4:5f:01:ad:a0:da";
              # Wifi
              hw-address = "e4:5f:01:ad:a0:db";
            }
            {
              hostname = "rpi4b8c";
              ip-address = "10.1.0.9";
              # Ethernet
              # hw-address = "e4:5f:01:ad:9f:27";
              # Wifi
              hw-address = "e4:5f:01:ad:9f:28";
            }
            {
              hostname = "rpi4b4a";
              ip-address = "10.1.0.10";
              # Ethernet
              # hw-address = "dc:a6:32:09:ce:24";
              # Wifi
              hw-address = "dc:a6:32:09:ce:25";
            }
            # Mac Mini m1 (Ethernet)
            {
              hostname = "MacMini-M1";
              ip-address = "10.1.0.11";
              # Ethernet
              hw-address = "4c:20:b8:de:e4:01";
              # Wifi
              # hw-address = "4c:20:b8:df:d1:5b";
            }
            {
              hostname = "MacMini-Intel";
              ip-address = "10.1.0.12";
              # Ethernet
              hw-address = "14:c2:13:ed:e6:ed";
              # Wifi
              # hw-address = "f0:18:98:8a:6d:ee";
            }
          ];
        }
      ];
      option-data = [
        {
          name = "domain-name-servers";
          data = "10.1.0.1";
        }
        {
          name = "domain-search";
          data = "diekvoss.internal, diekvoss.net, diekvoss.com";
        }
      ];
      loggers = [
        {
          name = "kea-dhcp4";
          output_options = [
            {
              output = "/var/lib/kea/kea-dhcp4.log";
              maxver = 10;
            }
          ];
          severity = "INFO";
        }
      ];
    };
  };
}
