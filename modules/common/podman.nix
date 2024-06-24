{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.virtualisation.podman.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
    ] ++ lib.optionals config.virtualisation.podman.dockerCompat [
      (runCommand "${podman-compose.pname}-docker-compat-${podman-compose.version}"
        {
          outputs = [ "out" ];
          inherit (podman-compose) meta;
        } ''
        mkdir -p $out/bin
        ln -s ${podman-compose}/bin/podman-compose $out/bin/docker-compose
      '')
    ];
  };
}

