# TODO: I plan on switching to this over systemd networkd but not finished yet, need more research on kea configuration
# probably a good oportunity to implement this on the backup router, Protectli
{
  kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "enp3s0"
          "enp4s0"
          "enp5s0"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      subnet4 = [
        {
          pools = [
            {
              pool = "10.1.0.100 - 10.1.0.240";
            }
          ];
          subnet = "10.1.0.0/24";
          # TODO: I don't know what this option means, is it the default gateway?
          option-data = [
            {
              name = "routers";
              data = "192.0.2.254";
            }
          ];
          reservations = [
            # Omada Controller
            {
              ip-address = "10.1.0.2";
              hw-address = "10:27:f5:bd:04:97";
            }
            # nas
            # if changing ip, change A record on cloudflare
            {
              ip-address = "10.1.0.3";
              hw-address = "30:9c:23:ad:79:43";
            }
            # Canon Printer (wifi)
            {
              ip-address = "10.1.0.4";
              hw-address = "c4:ac:59:a6:63:33";
            }
            # HP Printer (wifi)
            {
              ip-address = "10.1.0.5";
              hw-address = "7c:4d:8f:91:d3:9f";
            }
            # Backup / testing router (Ethernet)
            {
              ip-address = "10.1.0.6";
              # other ethernet ports 00:e0:67:2c:15:f1, 00:e0:67:2c:15:f2, 00:e0:67:2c:15:f3
              hw-address = "00:e0:67:2c:15:f0";
            }
            # rpi4b8a (wifi)
            {
              ip-address = "10.1.0.7";
              # ethernet port e4:5f:01:ad:81:3b
              hw-address = "e4:5f:01:ad:81:3d";
            }
            # rpi4b8b (wifi)
            {
              ip-address = "10.1.0.8";
              # ethernet port e4:5f:01:ad:a0:da
              hw-address = "e4:5f:01:ad:a0:db";
            }
            # rpi4b8c (wifi)
            {
              ip-address = "10.1.0.9";
              # ethernet port e4:5f:01:ad:9f:27
              hw-address = "e4:5f:01:ad:9f:28";
            }
            # rpi4b4a (wifi)
            {
              ip-address = "10.1.0.10";
              # ethernet port dc:a6:32:09:ce:24
              hw-address = "dc:a6:32:09:ce:25";
            }
            # Mac Mini m1 (Ethernet)
            {
              ip-address = "10.1.1.11";
              hw-address = "4c:20:b8:de:e4:01";
              # Wifi
              # hw-address = "4c:20:b8:df:d1:5b";
            }
            # Mac Mini Intel (Wifi)
            {
              ip-address = "10.1.0.12";
              # ethernet port 14:c2:13:ed:e6:ed
              hw-address = "f0:18:98:8a:6d:ee";
            }
          ];
        }
        {
          pools = [
            {
              pool = "10.1.1.100 - 10.1.1.240";
            }
          ];
          subnet = "10.1.1.0/24";
        }
        {
          pools = [
            {
              pool = "10.1.2.100 - 10.1.2.240";
            }
          ];
          subnet = "10.1.2.0/24";
        }
      ];
      valid-lifetime = 28800;
      option-data = [
        {
          name = "domain-name-servers";
          data = "10.1.0.1";
        }
      ];
      loggers = [
        {
          name = "kea-dhcp4";
          output_options = [
            {
              output = "/tmp/kea-dhcp4.log";
              maxver = 10;
            }
          ];
          severity = "INFO";
        }
      ];
    };
  };
}
