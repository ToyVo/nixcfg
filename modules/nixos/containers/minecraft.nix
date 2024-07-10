{ config, lib, pkgs, ... }:
let
  cfg = config.containerPresets;
in
{
  options.containerPresets = {
    minecraft = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25575;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      downloadsdir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store manually downloaded mods";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
    minecraft-ftb = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25575;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
  };

  config = lib.mkIf (cfg.minecraft.enable || cfg.minecraft-ftb.enable) {
    sops.secrets."minecraft_docker.env" = { };
    containerPresets.podman.enable = lib.mkDefault true;
    networking.firewall.allowedTCPPorts = lib.optionals cfg.minecraft.openFirewall [ cfg.minecraft.port ]
      ++ lib.optionals cfg.minecraft-ftb.openFirewall [ cfg.minecraft-ftb.port ];
    virtualisation.oci-containers.containers = {
      minecraft-ftb = lib.mkIf cfg.minecraft-ftb.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        # I plan to make a web interface that I want to be able to use RCON to get information but keep it internal
        ports = [ "${toString cfg.minecraft-ftb.port}:25565" "${toString cfg.minecraft-ftb.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          MEMORY = "20g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          MOTD = "ToyVo Direwolf20 Custom Server";
          TYPE = "FTBA";
          FTB_MODPACK_ID = "119";
          FTB_MODPACK_VERSION_ID = "11614";
          # FTB_FORCE_REINSTALL = "true";
          MAX_TICK_TIME = "-1";
          MAX_WORLD_SIZE = "128000";
          PATCH_DEFINITIONS = "/data/patches";
        };
        volumes = [
          "${cfg.minecraft-ftb.datadir}:/data"
        ];
      };
    };
    # The need to read a secret for CF_API_KEY is the reason why I'm using systemd instead of oci-containers to manually control escaping
    systemd.services.podman-minecraft = let
      name = "minecraft";
      escapedName = lib.escapeShellArg name;
      preStartScript = pkgs.writeShellApplication {
        name = "pre-start";
        runtimeInputs = [ ];
        text = ''
          podman rm -f ${name} || true
          rm -f /run/podman-${escapedName}.ctr-id
        '';
      };
      # Known mod ids that aren't needed
      # 220333 "cofh-lib" last available for 1.7.10
      # 227083 "baubles" last available for 1.12.2
      # 228816 "openblocks" last available for 1.12.2
      # 238222 "jei" incompatible with "roughly-enough-items-hacks"
      # 242942 "ic2-classic" last available for 1.12.2
      # 244651 "tesla" last available for 1.12.2
      # 247560 "oh-the-biomes-youll-go" last available for 1.19.4
      # 253449 "hwyla" last available for 1.16.5 we have wthit-forge instead
      # 261348 "avaritia-1-10" last available for 1.18.2
      # 267602 "ctm" not available for 1.20.1 but is for 1.19.2, 1.20.4+
      # 270789 "redstone-flux" last available for 1.12.2
      # 313272 "enchantability" last available for 1.16.5
      # 358877 "industrial-reborn" last available for 1.19.2
      # 368223 "health-overlay" last available for 1.19.3 we have colorful-hearts instead
      # 437654 "oc2" last available for 1.18.2
      # 440979 "wthit" fabric version we have the forge version
      # 449945 "perviaminvenire" last available for 1.19.2
      # 475110 "i-like-wood-oh-the-biomes-youll-go-plugin" last available for 1.19.2
      # 486392 "flywheel" last available for 1.19.2
      # 632048 "voluminous-energy-integrations-addon" last available for 1.19.2
      # 682881 "pluto" last available for 1.19.3
      # 74072 "tinkers-construct" last available for 1.19.2
      # 74924 "mantle" last available for 1.19.2

      # Manual downloads
      # "blaze-gear" # 418589 mc-image-helper says author doesn't allow automated downloads
      # "i-like-wood-twilight-forest-plugin" # 661721 mc-image-helper says author doesn't allow automated downloads
      # "ifly" # mc-image-helper says author doesn't allow automated downloads
      # "immersive-engineering" # 231951 mc-image-helper says unable to find match in latest files. Latest file is for neoforge, guessing the matching doesn't accout for forge/neoforge compatibility, manually put in neoforge version.
      # "shrink_" # mc-image-helper says mod file reference is not valid. Even when putting in full url to file, put in manually.
      mods = lib.strings.concatMapStringsSep "," (mod: "https://www.curseforge.com/minecraft/mc-mods/${mod}") [
        # "accelerated-decay"
        # "ad-astra"
        # "ad-astra-giselle-addon"
        # "advanced-generators"
        # "advanced-peripherals"
        # "ae2-things-forge"
        # "aecapfix"
        # "aerial-hell"
        # "aether"
        # "aether-enhanced-extinguishing"
        # "aethersteel"
        # "aethersteel-tweaks"
        # "ai-improvements"
        # "alexs-caves"
        # "almost-unified"
        # "angel-block-renewed"
        # "angel-ring"
        # "antsportation"
        # "apotheosis"
        # "apothic-attributes"
        # "appleskin"
        # "applied-botanics-addon"
        # "applied-cooking"
        # "applied-energistics-2"
        # "applied-energistics-2-wireless-terminals"
        # "applied-mekanistics"
        # "appliede"
        # "architectury-api"
        # "argonauts"
        # "ars-creo"
        # "ars-energistique"
        # "ars-nouveau"
        # "ars-ocultas"
        # "athena"
        # "attributefix"
        # "autumnity"
        # "badpackets"
        # "balm"
        # "bamboo-everything"
        # "baubley-heart-canisters"
        # "bdlib"
        # "bendy-lib"
        # "better-advancements"
        # "better-combat-by-daedelus"
        # "better-compatibility-checker"
        # "better-than-bunnies"
        # "better-than-llamas"
        # "biomes-o-plenty"
        # "blood-magic"
        # "blueprint"
        # "bookshelf"
        # "bosses-of-mass-destruction-forge"
        # "botania"
        # "botarium"
        # "brandons-core"
        # "building-gadgets"
        # "cable-tiers"
        # "cadmus"
        # "caelus"
        # "canary"
        # "catalogue"
        # "cc-tweaked"
        # "cerbons-api"
        # "charging-gadgets"
        # "chisels-bits"
        # "citadel"
        # "clean-swing-through-grass"
        # "cloth-config"
        # "clumps"
        # "cobweb"
        # "codechicken-lib-1-8"
        # "cofh-core"
        # "colorful-hearts"
        # "comforts"
        # "common-capabilities"
        # "config-menus-forge"
        # "configured"
        # "connected-glass"
        # "connectivity"
        # "construction-wand"
        # "controlling"
        # "cooking-for-blockheads"
        # "crafting-tweaks"
        # "crafttweaker"
        # "create"
        # "create-chunkloading"
        # "create-teleporters"
        # "createaddition"
        # "createtweaker"
        # "creeperhost-minetogether"
        # "creeperhost-presents-soul-shards"
        # "crossroads-mc"
        # "cucumber"
        # "cumulus"
        # "cupboard"
        # "curios"
        # "cyclic"
        # "cyclops-core"
        # "dark-mode-everywhere"
        # "dark-utilities"
        # "decorative-blocks"
        # "deep-resonance"
        # "default-options"
        # "default-server-properties"
        # "ding"
        # "draconic-evolution"
        # "eccentric-tome"
        # "edivadlib"
        # "electrodynamics"
        # "elytra-slot"
        # "embers-rekindled"
        # "emi"
        # "emojiful"
        # "enchantment-descriptions"
        # "ender-io"
        # "enderchests"
        # "endertanks"
        # "energized-power"
        # "entangled"
        # "essentials"
        # "experience-obelisk"
        # "extreme-reactors"
        # "extreme-sound-muffler"
        # "factorium"
        # "fancymenu"
        # "farmers-delight"
        # "farming-for-blockheads"
        # "fastfurnace"
        # "fastsuite"
        # "female-gender-forge"
        # "findme"
        # "flan-forge"
        # "flat-bedrock"
        # "flib"
        # "flower-patch"
        # "flux-networks"
        # "forbidden-arcanus"
        # "framedblocks"
        # "ftb-backups-2"
        # "ftb-chunks-forge"
        # "ftb-essentials"
        # "ftb-library-forge"
        # "ftb-ranks-forge"
        # "ftb-teams-forge"
        # "functional-armor-trim"
        # "functional-storage"
        # "fusion-connected-textures"
        # "game-stages"
        # "gateways-to-eternity"
        # "geckolib"
        # "gregtechceu-modern"
        # "growthcraft-community-edition"
        # "gunpowderlib"
        # "hammer-lib"
        # "handcrafted"
        # "harvest-with-ease"
        # "haunted-harvest"
        # "hole-filler-mod"
        # "hostile-neural-networks"
        # "hyperbox"
        "i-like-wood"
        # "i-like-wood-biomes-o-plenty-plugin"
        # "ice-and-fire-dragons"
        # "ichunutil"
        # "industrial-foregoing"
        # "industrial-foregoing-souls"
        # "integrated-crafting"
        # "integrated-dynamics"
        # "integrated-terminals"
        # "integrated-tunnels"
        # "inventory-essentials"
        # "inventory-sorter"
        # "iron-bookshelves"
        # "iron-chests"
        # "iron-furnaces"
        # "iron-jetpacks"
        # "irons-spells-n-spellbooks"
        # "item-collectors"
        # "item-production-lib"
        # "jade"
        # "jamd"
        # "jaopca"
        # "javd"
        # "jeitweaker"
        # "json-things"
        # "jumbo-furnace"
        # "jumpy-boats"
        # "just-enough-archaeology"
        # "just-enough-effect-descriptions-jeed"
        # "just-enough-resources-jer"
        # "justhammers"
        # "kleeslabs"
        # "konkrete"
        # "kotlin-for-forge"
        # "kubejs"
        # "kubejs-additions"
        # "kubejs-create"
        # "kubejs-enderio"
        # "kubejs-thermal"
        # "l2-archery"
        # "l2-artifacts"
        # "l2-backpack"
        # "l2-complements"
        # "l2hostility"
        # "l2library"
        # "l2weaponry"
        # "laserio"
        # "ldlib"
        # "lemon-lib"
        # "lendercataclysm"
        # "let-me-despawn"
        # "libx"
        # "light-overlay"
        # "lionfish-api"
        # "lootjs"
        # "lootr"
        # "luggage"
        # "macaws-bridges"
        # "macaws-doors"
        # "map-atlases-forge"
        # "max-health-fix"
        # "mcjtylib"
        # "measurements"
        # "mega-cells"
        # "mekanism"
        # "mekanism-additions"
        # "mekanism-generators"
        # "mekanism-tools"
        # "melody"
        # "merequester"
        # "mffs"
        # "mining-gadgets"
        # "mmmmmmmmmmmm"
        # "mob-grinding-utils"
        # "mod-name-tooltip"
        # "model-gap-fix"
        # "modernfix"
        # "modonomicon"
        # "modular-routers"
        # "modulargolems"
        # "more-dragon-eggs"
        # "more-red"
        # "more-red-x-cc-tweaked-compat"
        # "mouse-tweaks"
        # "mowlib"
        # "mowzies-mobs"
        # "mutant-monsters"
        # "mute"
        # "natures-aura"
        # "natures-compass"
        # "neat"
        # "nomowanderer"
        # "nuclearcraft-neoteric"
        # "occultism"
        # "open-loader"
        # "openblocks-elevator"
        # "openblocks-trophies"
        # "overweight-farming"
        # "passive-skill-tree"
        # "patchouli"
        # "pedestals"
        # "peripheralium"
        # "pig-pen-cipher"
        # "pipez"
        # "placebo"
        # "player-plates"
        # "playeranimator"
        # "pneumaticcraft-repressurized"
        # "pocket-storage"
        # "polylib"
        # "polymorph"
        # "powah-rearchitected"
        # "productivebees"
        # "projecte"
        # "puzzles-lib"
        # "quark"
        # "railcraft-reborn"
        # "rain-shield"
        # "ranged-pumps"
        # "rats"
        # "rebornstorage"
        # "rechiseled"
        # "rechiseled-create"
        # "recipe-stages"
        # "refined-cooking"
        # "refined-storage"
        # "refined-storage-addons"
        # "resourceful-config"
        # "resourceful-lib"
        # "rftools-base"
        # "rftools-builder"
        # "rftools-control"
        # "rftools-dimensions"
        # "rftools-power"
        # "rftools-storage"
        # "rftools-utility"
        # "rhino"
        # "roughly-enough-items"
        # "roughly-enough-items-hacks" # incompatible with "jei"
        # "rs-requestify"
        # "rsinfinitybooster"
        # "runelic"
        # "saturn"
        # "save-your-pets"
        # "scalable-cats-force"
        # "searchables"
        # "sebastrnlib"
        # "selene"
        # "serene-seasons"
        # "serverconfig-updater"
        # "shetiphiancore"
        # "shimmer"
        # "simple-discord-rich-presence"
        # "simple-magnets"
        # "simple-sponge"
        # "simply-graves"
        # "simply-light"
        # "slice-and-dice"
        # "smartbrainlib"
        # "smooth-boot-reloaded"
        # "smooth-chunk-save"
        # "snowy-spirit"
        # "solar-flux-reborn"
        # "sophisticated-backpacks"
        # "sophisticated-core"
        # "sophisticated-storage"
        # "soul-fire-d"
        # "spark"
        # "structure-compass"
        # "stylish-effects"
        # "supermartijn642s-config-lib"
        # "supermartijn642s-core-lib"
        # "supplementaries"
        # "sushigocrafting"
        # "team-projecte"
        # "tempad"
        # "terrablender"
        # "tesseract"
        # "the-bumblezone-forge"
        # "the-lost-cities"
        # "the-one-probe"
        "the-twilight-forest"
        # "the-undergarden"
        # "themcbroslib"
        # "thermal-cultivation"
        # "thermal-dynamics"
        # "thermal-expansion"
        # "thermal-foundation"
        # "thermal-innovation"
        # "thermal-integration"
        # "thermal-locomotion"
        # "theurgy"
        # "time-in-a-bottle-curio-support"
        # "time-in-a-bottle-universal"
        # "tiny-coal"
        # "titanium"
        # "toast-control"
        # "tome-of-blood-rebirth"
        # "tool-kit"
        # "torchmaster"
        # "touhou-little-maid"
        # "trample-stopper"
        # "trash-cans"
        # "travel-anchors"
        # "trenzalore"
        # "tropicraft"
        # "unlimitedperipheralworks"
        # "use-item-on-block-event"
        # "useful-foundation"
        # "useful-machinery"
        # "valhelsia-core"
        # "voluminous-energy"
        # "waddles"
        # "waystones"
        # "when-dungeons-arise"
        # "wireless-chargers"
        # "wormhole-portals"
        # "wthit-forge"
        # "xnet"
        # "xycraft"
        # "xycraft-machines"
        # "xycraft-override"
        # "xycraft-world"
        # "yeetusexperimentus"
        # "yungs-api"
        # "yungs-better-dungeons"
        # "yungs-better-mineshafts-forge"
        # "yungs-bridges"
        # "zerocore"
        # "zeta"
      ];
    in {
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      requires = [];
      environment = config.networking.proxy.envVars;

      path = [config.virtualisation.podman.package];
      script = "export CF_API_KEY=$(cat ${config.sops.secrets.forge_api_key.path})\n" +
      lib.concatStringsSep " \\\n  " ([
        "exec podman"
        "run"
        "--rm"
        "--name=${escapedName}"
        "--log-driver=journald"
        "--cidfile=/run/podman-${escapedName}.ctr-id"
        "--cgroups=no-conmon"
        "--sdnotify=conmon"
        "-d"
        "--replace"
        "-e EULA='TRUE'"
        "-e TYPE='MOHIST'"
        "-e VERSION='1.20.1'"
        "-e MEMORY='20g'"
        "-e OPS='4cb4aff4-a0ed-4eaf-b912-47825b2ed30d'"
        "-e EXISTING_OPS_FILE='MERGE'"
        "-e MOTD='ToyVo Custom Server'"
        "-e CF_API_KEY=$CF_API_KEY"
        "-e CURSEFORGE_FILES='${mods}'"
        "-p '${toString cfg.minecraft.port}:25565'"
        "-p '${toString cfg.minecraft.RCONPort}:25575'"
        "-v '${cfg.minecraft.datadir}:/data'"
        "-v '${cfg.minecraft.downloadsdir}:/downloads'"
        "docker.io/itzg/minecraft-server:latest"
      ]);

      preStop = "podman stop --ignore --cidfile=/run/podman-${escapedName}.ctr-id";

      postStop = "podman rm -f --ignore --cidfile=/run/podman-${escapedName}.ctr-id";

      serviceConfig = {
        ExecStartPre = [ "${preStartScript}/bin/pre-start" ];
        TimeoutStartSec = 0;
        TimeoutStopSec = 120;
        Restart = "always";
        Environment="PODMAN_SYSTEMD_UNIT=podman-${name}.service";
        Type="notify";
        NotifyAccess="all";
      };
    };
  };
}
