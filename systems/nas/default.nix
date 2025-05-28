{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./samba.nix ];

  hardware.cpu.amd.updateMicrocode = true;
  networking = {
    hostName = "nas";
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
        8080
        7080
      ];
      allowedUDPPorts = [
        53
        443
        8080
        7080
      ];
    };
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.chloe.enable = true;
  userPresets.toyvo.enable = true;
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    remote-builds.server.enable = true;
    ollama.enable = true;
    spice-vdagentd.enable = true;
    # discord_bot = {
    #   enable = true;
    #   env_file = config.sops.secrets."discord_bot.env".path;
    #   env = {
    #     MINECRAFT_GEYSER_ADDRESS = "mc.toyvo.dev:25566";
    #     MINECRAFT_MODDED_ADDRESS = "mc.toyvo.dev:25565";
    #     TERRARIA_ADDRESS = "mc.toyvo.dev:7777";
    #     TSHOCK_REST_BASE_URL = "https://mc.toyvo.dev";
    #     IP = "0.0.0.0";
    #     BASE_URL = "https://toyvo.dev";
    #     CLOUD_SSH_HOST = "discord_bot@mc.toyvo.dev";
    #     CLOUD_SSH_KEY = config.sops.secrets.cloud_ssh_ed25519.path;
    #   };
    # };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    coder = {
      enable = true;
      accessUrl = "https://coder.diekvoss.net";
      listenAddress = "0.0.0.0:7080";
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
    };
    homepage-dashboard = {
      enable = true;
      openFirewall = true;
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
    deluge = {
      enable = true;
      web = {
        enable = true;
        openFirewall = true;
      };
    };
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
    };
    home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "F";
        };
        http = {
          base_url = "https://home-assistant.diekvoss.net";
          use_x_forwarded_for = true;
          trusted_proxies = [ "10.1.0.1" ];
        };
      };
    };
    nextcloud = rec {
      enable = true;
      hostName = "nextcloud.diekvoss.net";
      config = {
        adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
        adminuser = config.users.users.toyvo.name;
        dbtype = "pgsql";
      };
      database.createLocally = true;
      package = pkgs.nextcloud31;
      extraApps = {
        inherit (package.packages.apps) news contacts calendar tasks richdocuments bookmarks music mail notes cookbook;
      };
      extraAppsEnable = true;
    };
  };
  sops.secrets = {
    nextcloud_admin_password.owner = "nextcloud";
    #   "discord_bot.env" = {
    #     owner = "discord_bot";
    #   };
    #   cloud_ssh_ed25519 = {
    #     owner = "discord_bot";
    #   };
  };
  containerPresets = {
    podman.enable = true;
    open-webui = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/POOL/open-webui";
      port = 11435;
    };
    portainer = {
      enable = true;
      openFirewall = true;
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users.toyvo.extraGroups = [ "libvirtd" ];
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    bottles
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    guestfs-tools
    libosinfo
    win-spice
    distrobox
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
