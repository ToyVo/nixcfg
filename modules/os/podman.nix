{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.virtualisation.podman.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
      docker-compose
    ];
  };
}

