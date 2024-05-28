{ ... }: {
  services = {
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      enable = true;
      openFirewall = true;
      extraConfig = ''
        netbios name = ncasesmb
        security = user
        server role = standalone server
        hosts allow = 10.1.0.0/24 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        public = {
          path = "/mnt/POOL/Public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "share";
          "force group" = "users";
          "valid users" = "@users";
        };
        collin = {
          path = "/mnt/POOL/Collin";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "toyvo";
          "force group" = "users";
          "valid users" = "toyvo";
        };
        chloe = {
          path = "/mnt/POOL/Chloe";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "chloe";
          "force group" = "users";
          "valid users" = "chloe";
        };
      };
    };
  };
}
