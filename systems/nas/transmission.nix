{
  config,
  pkgs,
  lib,
  homelab,
  ...
}:
let
  wireguardInterface = "wg0";
  wireguardInterfaceNamespace = "protonvpn0";
  wireguardGateway = "10.2.0.1";
  inherit (config.networking) hostName;
in
{
  config = lib.mkIf config.services.transmission.enable {
    sops.secrets."protonvpn-US-IL-503.key" = { };
    services.transmission = {
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        rpc-port = homelab.${hostName}.services.transmission.port;
        bind-address-ipv4 = "0.0.0.0";
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "127.0.0.1,10.1.0.*";
        rpc-host-whitelist = "${config.networking.hostName}.internal,transmission.diekvoss.net";
        download-dir = "/mnt/POOL/transmission/Downloads";
      };
      group = "multimedia";
    };
    networking.wireguard.interfaces.${wireguardInterface} = {
      privateKeyFile = config.sops.secrets."protonvpn-US-IL-503.key".path;
      ips = [ "10.2.0.2/32" ];
      peers = [
        {
          publicKey = "Ad0UnBi3NeIgVpM1baC8HAp6wfSli0wGS1OCmS7uYRo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "79.127.187.156:51820";
        }
      ];
      interfaceNamespace = wireguardInterfaceNamespace;
      preSetup = ''ip netns add "${wireguardInterfaceNamespace}"'';
      postSetup = ''
        ip -n "${wireguardInterfaceNamespace}" link set up dev "lo"
        ip -n "${wireguardInterfaceNamespace}" route add default dev "${wireguardInterface}"
      '';
      preShutdown = ''ip -n "${wireguardInterfaceNamespace}" route del default dev "${wireguardInterface}"'';
      postShutdown = ''ip netns del "${wireguardInterfaceNamespace}"'';
    };
    environment.etc."netns/${wireguardInterfaceNamespace}/resolv.conf".text =
      "nameserver ${wireguardGateway}";
    systemd = {
      services = {
        transmission = {
          bindsTo = [ "wireguard-${wireguardInterface}.service" ];
          requires = [
            "network-online.target"
            "wireguard-${wireguardInterface}.service"
            "port-forward-transmission.service"
            "proxy-to-transmission.service"
          ];
          serviceConfig.NetworkNamespacePath = "/var/run/netns/${wireguardInterfaceNamespace}";
        };
        # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
        proxy-to-transmission = {
          enable = true;
          description = "Proxy to Transmission in Network Namespace";
          requires = [
            "proxy-to-transmission.socket"
          ];
          after = [
            "transmission.service"
            "proxy-to-transmission.socket"
          ];
          unitConfig = {
            JoinsNamespaceOf = "transmission.service";
          };
          serviceConfig = {
            User = "transmission";
            Group = "multimedia";
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
            PrivateNetwork = "yes";
          };
        };
        port-forward-transmission = {
          enable = true;
          bindsTo = [ "wireguard-${wireguardInterface}.service" ];
          requires = [
            "network-online.target"
            "wireguard-${wireguardInterface}.service"
          ];
          after = [ "transmission.service" ];
          description = "Port Forwarding for Transmission through ProtonVPN";
          unitConfig = {
            JoinsNamespaceOf = "transmission.service";
          };
          serviceConfig = {
            User = "transmission";
            Group = "multimedia";
            PrivateNetwork = "yes";
            ExecStart = pkgs.writeScript "port-forward-transmission.py" ''
              #!${pkgs.python3.withPackages (p: with p; [ transmission-rpc ])}/bin/python3
              import time
              import subprocess
              import transmission_rpc

              transmission = transmission_rpc.Client(port=${toString config.services.transmission.settings.rpc-port})

              while True:
                  try:
                      print(time.strftime("%Y-%m-%d %H:%M:%S"))
                      udp_result = subprocess.run(
                          ["${pkgs.libnatpmp}/bin/natpmpc", "-a", "1", "0", "udp", "60", "-g", "${wireguardGateway}"],
                          capture_output=True, text=True
                      )
                      tcp_result = subprocess.run(
                          ["${pkgs.libnatpmp}/bin/natpmpc", "-a", "1", "0", "tcp", "60", "-g", "${wireguardGateway}"],
                          capture_output=True, text=True
                      )

                      if udp_result.returncode == 0 and tcp_result.returncode == 0:
                          # Extract the port from the TCP result
                          for line in tcp_result.stdout.splitlines():
                              if line.startswith("Mapped public port"):
                                  port = int(line.split()[3])
                                  transmission.set_session(peer_port=port, port_forwarding_enabled=False)
                                  break
                      else:
                          print("ERROR with natpmpc command")
                          print("UDP Output:", udp_result.stdout)
                          print("TCP Output:", tcp_result.stdout)
                          break
                  except Exception as e:
                      print(f"Unexpected error: {e}")
                      break

                  time.sleep(45)
            '';
          };
        };
      };
      # allowing caddy to access transmission in network namespace, a socket is necesarry
      sockets.proxy-to-transmission = {
        enable = true;
        description = "Socket for Proxy to Transmission";
        listenStreams = [ (toString config.services.transmission.settings.rpc-port) ];
        wantedBy = [ "sockets.target" ];
      };
    };
  };
}
