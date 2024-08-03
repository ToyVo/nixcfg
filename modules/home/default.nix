{ pkgs, lib, config, ... }: {
  imports = [ ./alias-home-apps.nix ./users ./programs ];

  options.home = {
    symlinkPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.buildEnv { name = "home-symlink-packages"; paths = config.home.symlinkPackages; };
      description = "Package to be symlinked into the user's .local directory";
      internal = true;
    };
    symlinkPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages to be symlinked into the user's .local directory";
    };
  };

  config =
    let
      recursive_list_files = pkgs.writers.writeJS "recursive_list_files.js" { } ''
        const fs = require('node:fs/promises');
        const path = require('node:path');
        let result = {};

        const traverseDir = async (initialDir, initialSegments = []) => {
          const stack = [{ dir: initialDir, segments: initialSegments }];

          while (stack.length > 0) {
            const { dir, segments } = stack.pop();
            const listing = await fs.readdir(dir, { withFileTypes: true });

            for (const obj of listing) {
              const subPath = path.join(dir, obj.name);

              try {
                const stat = await fs.lstat(subPath);

                if (stat.isDirectory()) {
                  stack.push({ dir: subPath, segments: [...segments, obj.name] });
                } else if (stat.isFile()) {
                  const target = path.join(...segments, obj.name);
                  result[target] = { source: subPath };
                } else if (stat.isSymbolicLink()) {
                  let link = await fs.readlink(subPath);

                  if (!link.startsWith('/')) {
                    link = path.resolve(path.dirname(subPath), link);
                  }

                  const targetStat = await fs.lstat(link);
                  if (targetStat.isDirectory()) {
                    stack.push({ dir: link, segments: [...segments, obj.name] });
                  } else if (targetStat.isFile()) {
                    const target = path.join(...segments, obj.name);
                    result[target] = { source: link };
                  }
                }
              } catch (e) {
                // TODO: Handle errors (e.g., symlink target doesn't exist)
              }
            }
          }
        };

        traverseDir('${config.home.symlinkPackage}', ['.local']).then(() => {
          console.log(JSON.stringify(result));
        });
      '';
      files = pkgs.runCommand "recursive_list_files" { } ''
        echo -n $(${recursive_list_files}) > $out
      '';
    in
    {
      home.file = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile files));
      home.sessionVariables.SOPS_AGE_RECIPIENTS = config.sops.age.keyFile;
      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age = {
          keyFile = "${config.xdg.configHome}/sops-nix/key.txt";
          generateKey = true;
        };
      };
    };
}
