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
      mods = lib.strings.concatMapStringsSep "," (mod: "https://www.curseforge.com/minecraft/mc-mods/${mod}") [
        "accelerated-decay"
        "ad-astra"
        "ad-astra-giselle-addon"
        "advanced-generators"
        "advanced-peripherals"
        "ae2-things-forge"
        "aether"
        "aether-enhanced-extinguishing"
        "aethersteel"
        "aethersteel-tweaks"
        "ai-improvements"
        "almost-unified"
        "angel-block-renewed"
        "angel-ring"
        "antsportation"
        "apotheosis"
        "apothic-attributes"
        "appleskin"
        "applied-botanics-addon"
        "applied-cooking"
        "applied-energistics-2"
        "applied-energistics-2-wireless-terminals"
        "applied-mekanistics"
        "appliede"
        "architectury-api"
        "argonauts"
        "ars-creo"
        "ars-energistique"
        "ars-nouveau"
        "ars-ocultas"
        "athena"
        "attributefix"
        "avaritia-1-10"
        "balm"
        "bamboo-everything"
        "baubles"
        "baubley-heart-canisters"
        "bdlib"
        "bendy-lib"
        "better-compatibility-checker"
        "better-than-bunnies"
        "better-than-llamas"
        "biomes-o-plenty"
        "blaze-gear"
        "blood-magic"
        "bookshelf"
        "botania"
        "botarium"
        "brandons-core"
        "building-gadgets"
        "cable-tiers"
        "cadmus"
        "caelus"
        "canary"
        "cc-tweaked"
        "charging-gadgets"
        "chisels-bits"
        "citadel"
        "clean-swing-through-grass"
        "cloth-config"
        "clumps"
        "cobweb"
        "codechicken-lib-1-8"
        "cofh-core"
        "cofh-lib"
        "colorful-hearts"
        "comforts"
        "common-capabilities"
        "configured"
        "connected-glass"
        "connectivity"
        "construction-wand"
        "controlling"
        "cooking-for-blockheads"
        "crafting-tweaks"
        "crafttweaker"
        "create"
        "create-chunkloading"
        "create-teleporters"
        "createaddition"
        "createtweaker"
        "creeperhost-minetogether"
        "creeperhost-presents-soul-shards"
        "crossroads-mc"
        "ctm"
        "cucumber"
        "cumulus"
        "cupboard"
        "curios"
        "cyclic"
        "cyclops-core"
        "dark-mode-everywhere"
        "dark-utilities"
        "decorative-blocks"
        "deep-resonance"
        "default-options"
        "default-server-properties"
        "ding"
        "draconic-evolution"
        "eccentric-tome"
        "edivadlib"
        "electrodynamics"
        "elytra-slot"
        "embers-rekindled"
        "emojiful"
        "enchantability"
        "enchantment-descriptions"
        "ender-io"
        "enderchests"
        "endertanks"
        "energized-power"
        "entangled"
        "experience-obelisk"
        "extreme-reactors"
        "extreme-sound-muffler"
        "factorium"
        "fancymenu"
        "farmers-delight"
        "farming-for-blockheads"
        "fastfurnace"
        "fastsuite"
        "female-gender-forge"
        "findme"
        "flan-forge"
        "flat-bedrock"
        "flib"
        "flower-patch"
        "flux-networks"
        "flywheel"
        "forbidden-arcanus"
        "framedblocks"
        "ftb-backups-2"
        "ftb-chunks-forge"
        # "ftb-essentials-forge"
        "ftb-library-forge"
        "ftb-ranks-forge"
        "ftb-teams-forge"
        "functional-armor-trim"
        "functional-storage"
        "fusion-connected-textures"
        "game-stages"
        "gateways-to-eternity"
        "geckolib"
        "gregtechceu-modern"
        "growthcraft-community-edition"
        "gunpowderlib"
        "hammer-lib"
        "handcrafted"
        "harvest-with-ease"
        "haunted-harvest"
        "health-overlay"
        "hole-filler-mod"
        "hostile-neural-networks"
        "hwyla"
        "hyperbox"
        "i-like-wood"
        "i-like-wood-biomes-o-plenty-plugin"
        "i-like-wood-oh-the-biomes-youll-go-plugin"
        "ic2-classic"
        "ichunutil"
        # "ifly"
        "immersive-engineering"
        "industrial-foregoing"
        "industrial-foregoing-souls"
        "industrial-reborn"
        "integrated-crafting"
        "integrated-dynamics"
        "integrated-terminals"
        "integrated-tunnels"
        "inventory-essentials"
        "inventory-sorter"
        "iron-bookshelves"
        "iron-chests"
        "iron-furnaces"
        "iron-jetpacks"
        "irons-spells-n-spellbooks"
        "item-collectors"
        "jade"
        "jamd"
        "jaopca"
        "javd"
        "jei"
        "jeitweaker"
        "json-things"
        "jumbo-furnace"
        "jumpy-boats"
        "just-enough-archaeology"
        "just-enough-resources-jer"
        "justhammers"
        "kleeslabs"
        "konkrete"
        "kotlin-for-forge"
        "kubejs"
        "kubejs-additions"
        "kubejs-create"
        "kubejs-enderio"
        "kubejs-thermal"
        "l2-archery"
        "l2-backpack"
        "l2-complements"
        "l2hostility"
        "l2library"
        "l2weaponry"
        "laserio"
        "lemon-lib"
        "lendercataclysm"
        "let-me-despawn"
        "libx"
        "light-overlay"
        "lionfish-api"
        "lootjs"
        "lootr"
        "luggage"
        "macaws-bridges"
        "macaws-doors"
        "mantle"
        "map-atlases-forge"
        "max-health-fix"
        "mcjtylib"
        "measurements"
        "mega-cells"
        "mekanism"
        "mekanism-additions"
        "mekanism-generators"
        "mekanism-tools"
        "melody"
        "merequester"
        "mffs"
        "mining-gadgets"
        "mmmmmmmmmmmm"
        "mob-grinding-utils"
        "mod-name-tooltip"
        "model-gap-fix"
        "modernfix"
        "modonomicon"
        "modular-routers"
        "modulargolems"
        "more-dragon-eggs"
        "more-red"
        "more-red-x-cc-tweaked-compat"
        "mouse-tweaks"
        "mowlib"
        "mute"
        "natures-aura"
        "natures-compass"
        "neat"
        "nomowanderer"
        "nuclearcraft-neoteric"
        "oc2"
        "occultism"
        "oh-the-biomes-youll-go"
        "open-loader"
        "openblocks"
        "openblocks-elevator"
        "openblocks-trophies"
        "overweight-farming"
        "patchouli"
        "pedestals"
        "peripheralium"
        "perviaminvenire"
        "pig-pen-cipher"
        "pipez"
        "placebo"
        "player-plates"
        "playeranimator"
        "pluto"
        "pneumaticcraft-repressurized"
        "pocket-storage"
        "polylib"
        "polymorph"
        "productivebees"
        "projecte"
        "quark"
        "railcraft-reborn"
        "rain-shield"
        "ranged-pumps"
        "rats"
        "rebornstorage"
        "rechiseled"
        "rechiseled-create"
        "recipe-stages"
        "redstone-flux"
        "refined-cooking"
        "refined-storage"
        "refined-storage-addons"
        "resourceful-config"
        "resourceful-lib"
        "rftools-base"
        "rftools-builder"
        "rftools-control"
        "rftools-dimensions"
        "rftools-power"
        "rftools-storage"
        "rftools-utility"
        "rhino"
        "roughly-enough-items"
        "rs-requestify"
        "rsinfinitybooster"
        "runelic"
        "saturn"
        "save-your-pets"
        "scalable-cats-force"
        "searchables"
        "sebastrnlib"
        "selene"
        "serverconfig-updater"
        "shetiphiancore"
        "shimmer"
        # "shrink_"
        "simple-discord-rich-presence"
        "simple-magnets"
        "simple-sponge"
        "simply-graves"
        "simply-light"
        "slice-and-dice"
        "smartbrainlib"
        "smooth-boot-reloaded"
        "smooth-chunk-save"
        "snowy-spirit"
        "solar-flux-reborn"
        "sophisticated-backpacks"
        "sophisticated-core"
        "sophisticated-storage"
        "spark"
        "structure-compass"
        "supermartijn642s-config-lib"
        "supermartijn642s-core-lib"
        "supplementaries"
        "sushigocrafting"
        "tempad"
        "terrablender"
        "tesla"
        "tesseract"
        "the-bumblezone-forge"
        "the-lost-cities"
        "the-one-probe"
        "the-twilight-forest"
        "thermal-cultivation"
        "thermal-dynamics"
        "thermal-expansion"
        "thermal-foundation"
        "thermal-innovation"
        "thermal-integration"
        "thermal-locomotion"
        "theurgy"
        "time-in-a-bottle-curio-support"
        "time-in-a-bottle-universal"
        "tinkers-construct"
        "tiny-coal"
        "titanium"
        "toast-control"
        "tome-of-blood-rebirth"
        "tool-kit"
        "torchmaster"
        "touhou-little-maid"
        "trample-stopper"
        "trash-cans"
        "travel-anchors"
        "trenzalore"
        "tropicraft"
        "unlimitedperipheralworks"
        "use-item-on-block-event"
        "useful-machinery"
        "valhelsia-core"
        "voluminous-energy"
        "waddles"
        "waystones"
        "when-dungeons-arise"
        "wireless-chargers"
        "wormhole-portals"
        "wthit"
        "wthit-forge"
        "xnet"
        "xycraft"
        "xycraft-machines"
        "xycraft-override"
        "xycraft-world"
        "yeetusexperimentus"
        "yungs-api"
        "yungs-better-dungeons"
        "yungs-better-mineshafts-forge"
        "yungs-bridges"
        "zerocore"
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

