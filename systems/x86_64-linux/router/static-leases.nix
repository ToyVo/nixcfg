{ ... }: {
  systemd.network.networks."20-lan".dhcpServerStaticLeases = [
    # Omada Controller
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.2";
        MACAddress = "10:27:f5:bd:04:97";
      };
    }
    # NCase
    # if changing ip, change A record on cloudflare
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.3";
        MACAddress = "70:85:c2:8a:53:5b";
      };
    }
    # Canon Printer (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.4";
        MACAddress = "c4:ac:59:a6:63:33";
      };
    }
    # HP Printer (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.5";
        MACAddress = "7c:4d:8f:91:d3:9f";
      };
    }
    # Backup / testing router (Ethernet)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.6";
        # other ethernet ports 00:e0:67:2c:15:f1, 00:e0:67:2c:15:f2, 00:e0:67:2c:15:f3
        MACAddress = "00:e0:67:2c:15:f0";
      };
    }
    # rpi4b8a (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.7";
        # ethernet port e4:5f:01:ad:81:3b
        MACAddress = "e4:5f:01:ad:81:3d";
      };
    }
    # rpi4b8b (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.8";
        # ethernet port e4:5f:01:ad:a0:da
        MACAddress = "e4:5f:01:ad:a0:db";
      };
    }
    # rpi4b8c (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.9";
        # ethernet port e4:5f:01:ad:9f:27
        MACAddress = "e4:5f:01:ad:9f:28";
      };
    }
    # rpi4b4a (wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.10";
        # ethernet port dc:a6:32:09:ce:24
        MACAddress = "dc:a6:32:09:ce:25";
      };
    }
    # Mac Mini m1 (Wifi)
    {
      dhcpServerStaticLeaseConfig = {
        Address = "10.1.0.11";
        # ethernet port 4c:20:b8:de:e4:01
        MACAddress = "4c:20:b8:df:d1:5b";
      };
    }
  ];
}
