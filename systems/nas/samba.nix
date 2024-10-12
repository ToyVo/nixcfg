{ ... }:
{
  services = {
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "netbios name" = "nas";
          security = "user";
          "server role" = "standalone";
          "hosts allow" = "10.1.0.0/24 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
      };
      shares = {
        public = {
          path = "/mnt/POOL/Public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force user" = "nobody";
          "force group" = "users";
          "valid users" = "@users";
        };
        collin = {
          path = "/mnt/POOL/Collin";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0640";
          "directory mask" = "0750";
          "force user" = "toyvo";
          "force group" = "toyvo";
          "valid users" = "@toyvo";
        };
        chloe = {
          path = "/mnt/POOL/Chloe";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0640";
          "directory mask" = "0750";
          "force user" = "chloe";
          "force group" = "chloe";
          "valid users" = "@chloe";
        };
      };
    };
  };
}
