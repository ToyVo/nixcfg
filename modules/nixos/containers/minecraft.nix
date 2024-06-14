{ config, lib, ... }:
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
    minecraft-experimental = {
      enable = lib.mkEnableOption "Enable minecraft server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25564;
        description = "Port to expose minecraft server on";
      };
      RCONPort = lib.mkOption {
        type = lib.types.int;
        default = 25574;
        description = "Port to expose minecraft server on";
      };
      datadir = lib.mkOption {
        type = lib.types.path;
        description = "Path to store minecraft data";
      };
      openFirewall = lib.mkEnableOption "Open firewall for minecraft";
    };
  };

  config = lib.mkIf (cfg.minecraft.enable || cfg.minecraft-experimental.enable) {
    containerPresets.podman.enable = lib.mkDefault true;
    networking.firewall.allowedTCPPorts = [ ]
      ++ lib.optionals cfg.minecraft.openFirewall [ cfg.minecraft.port ]
      ++ lib.optionals cfg.minecraft-experimental.openFirewall [ cfg.minecraft-experimental.port ];
    virtualisation.oci-containers.containers = {
      minecraft = lib.mkIf cfg.minecraft.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        # I plan to make a web interface that I want to be able to use RCON to get information but keep it internal
        ports = [ "${toString cfg.minecraft.port}:25565" "${toString cfg.minecraft.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          MEMORY = "16g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          MOTD = "ToyVo Direwolf20 Custom Server";
          TYPE = "FTBA";
          FTB_MODPACK_ID = "119";
        };
        volumes = [
          "${cfg.minecraft.datadir}:/data"
        ];
      };
      minecraft-experimental = lib.mkIf cfg.minecraft-experimental.enable {
        image = "docker.io/itzg/minecraft-server:latest";
        ports = [ "${toString cfg.minecraft-experimental.port}:25565" "${toString cfg.minecraft-experimental.RCONPort}:25575" ];
        environment = {
          EULA = "TRUE";
          TYPE = "MOHIST";
          VERSION = "1.20.1";
          MEMORY = "4g";
          OPS = "4cb4aff4-a0ed-4eaf-b912-47825b2ed30d";
          EXISTING_OPS_FILE = "MERGE";
          MOTD = "ToyVo Custom Server";
          CF_API_KEY = lib.strings.removeSuffix "\n" (builtins.readFile ./forgeapikey);
          CURSEFORGE_FILES = lib.strings.concatMapStringsSep "," (mod: "https://www.curseforge.com/minecraft/mc-mods/${mod}")  [
            "projecte"
            "brandons-core"
            "codechicken-lib-1-8"
            "draconic-evolution"
            "accelerated-decay"
            "ad-astra"
            "ad-astra-giselle-addon"
            "advanced-generators"
            "advanced-peripherals"
            "ae2-things-forge"
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
            "architectury-api"
            "ars-creo"
            "ars-nouveau"
            "ars-ocultas"
            "athena"
            "attributefix"
            "balm"
            "bamboo-everything"
            "baubley-heart-canisters"
            "bdlib"
            "better-compatibility-checker"
            "better-than-bunnies"
            "better-than-llamas"
            "blood-magic"
            "bookshelf"
            "botania"
            "botarium"
            "building-gadgets"
            "cable-tiers"
            "caelus"
            "canary"
            "cc-tweaked"
            "charging-gadgets"
            "chisels-bits"
            "citadel"
            "clean-swing-through-grass"
            "cloth-config"
            "clumps"
            "cofh-core"
            "experience-obelisk"
            "colorful-hearts"
            "comforts"
            "common-capabilities"
            "connected-glass"
            "connectivity"
            "construction-wand"
            "controlling"
            "cooking-for-blockheads"
            "crafting-tweaks"
            "crafttweaker"
            "create"
            "create-teleporters"
            "create-chunkloading"
            "createaddition"
            "slice-and-dice"
            "createtweaker"
            "creeperhost-presents-soul-shards"
            "cucumber"
            "cupboard"
            "curios"
            "cyclic"
            "cyclops-core"
            "dark-utilities"
            "deep-resonance"
            "default-options"
            "default-server-properties"
            "ding"
            "eccentric-tome"
            "edivadlib"
            "elytra-slot"
            "emojiful"
            "enchantment-descriptions"
            "ender-io"
            "enderchests"
            "endertanks"
            "entangled"
            "extreme-reactors"
            "extreme-sound-muffler"
            "fancymenu"
            "farmers-delight"
            "farming-for-blockheads"
            "fastfurnace"
            "fastsuite"
            "findme"
            "flat-bedrock"
            "flib"
            "flower-patch"
            "flux-networks"
            "forbidden-arcanus"
            "framedblocks"
            "ftb-backups-2"
            "ftb-chunks-forge"
            "ftb-essentials-forge"
            "ftb-library-forge"
            "ftb-ranks-forge"
            "ftb-teams-forge"
            "functional-armor-trim"
            "functional-storage"
            "fusion-connected-textures"
            "gateways-to-eternity"
            "geckolib"
            "growthcraft-community-edition"
            "gunpowderlib"
            "hammer-lib"
            "handcrafted"
            "harvest-with-ease"
            "hole-filler-mod"
            "hostile-neural-networks"
            "hyperbox"
            "ifly"
            "industrial-foregoing"
            "industrial-foregoing-souls"
            "integrated-crafting"
            "integrated-dynamics"
            "integrated-terminals"
            "integrated-tunnels"
            "inventory-essentials"
            "inventory-sorter"
            "iron-chests"
            "iron-furnaces"
            "iron-jetpacks"
            "irons-spells-n-spellbooks"
            "item-collectors"
            "jamd"
            "jaopca"
            "jumpy-boats"
            "javd"
            "just-enough-archaeology"
            "jei"
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
            "lendercataclysm"
            "l2library"
            "laserio"
            "lemon-lib"
            "let-me-despawn"
            "libx"
            "light-overlay"
            "lootjs"
            "lootr"
            "luggage"
            "macaws-bridges"
            "macaws-doors"
            "max-health-fix"
            "mcjtylib"
            "merequester"
            "measurements"
            "mega-cells"
            "mekanism"
            "mekanism-additions"
            "mekanism-generators"
            "mekanism-tools"
            "creeperhost-minetogether"
            "mining-gadgets"
            "mmmmmmmmmmmm"
            "mob-grinding-utils"
            "mod-name-tooltip"
            "modernfix"
            "modonomicon"
            "mffs"
            "modulargolems"
            "modular-routers"
            "selene"
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
            "occultism"
            "openblocks-elevator"
            "openblocks-trophies"
            "patchouli"
            "pedestals"
            "peripheralium"
            "pig-pen-cipher"
            "pipez"
            "placebo"
            "player-plates"
            "playeranimator"
            "pneumaticcraft-repressurized"
            "pocket-storage"
            "polylib"
            "polymorph"
            "productivebees"
            "railcraft-reborn"
            "rain-shield"
            "ranged-pumps"
            "rats"
            "rebornstorage"
            "rechiseled"
            "rechiseled-create"
            "refined-cooking"
            "refined-storage"
            "refined-storage-addons"
            "rs-requestify"
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
            "rsinfinitybooster"
            "runelic"
            "save-your-pets"
            "scalable-cats-force"
            "searchables"
            "sebastrnlib"
            "smooth-chunk-save"
            "serverconfig-updater"
            "shetiphiancore"
            # "shrink_"
            "simple-discord-rich-presence"
            "simple-magnets"
            "simple-sponge"
            "simply-graves"
            "simply-light"
            "smartbrainlib"
            "smooth-boot-reloaded"
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
            "tesseract"
            "aether"
            "the-one-probe"
            "the-twilight-forest"
            "thermal-cultivation"
            "thermal-dynamics"
            "thermal-expansion"
            "thermal-foundation"
            "thermal-innovation"
            "thermal-integration"
            "thermal-locomotion"
            "time-in-a-bottle-forge"
            "time-in-a-bottle-curio-support"
            "tiny-coal"
            "titanium"
            "toast-control"
            "tome-of-blood-rebirth"
            "tool-kit"
            "torchmaster"
            "trample-stopper"
            "trash-cans"
            "travel-anchors"
            "trenzalore"
            "tropicraft"
            "unlimitedperipheralworks"
            "valhelsia-core"
            "waddles"
            "waystones"
            "when-dungeons-arise"
            "wireless-chargers"
            "wormhole-portals"
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
        };
        volumes = [
          "${cfg.minecraft-experimental.datadir}:/data"
        ];
      };
    };
  };
}

