{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    libsForQt5.dolphin
    wofi
    hyprpaper
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    recommendedEnvironment = true;
    extraConfig = ''
      monitor=,preferred,auto,1
      exec-once = waybar & hyprpaper & firefox
      input {
          kb_layout = us
          kb_options = ctrl:nocaps
      }

      general {
          gaps_in = 4
          gaps_out = 16
          border_size = 2
          col.active_border = rgba(ebbcbaee) rgba(31748fee) 45deg
          col.inactive_border = rgba(191724aa)
      }

      decoration {
          rounding = 8
          blur_size = 4
      }

      animations {
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      gestures {
          workspace_swipe = true
      }

      dwindle {
          pseudotile = true
          preserve_split = true
      }

      $mainMod = SUPER
      bind = $mainMod, Q, exec, wezterm
      bind = $mainMod, E, exec, dolphin
      bind = $mainMod, R, exec, wofi --show drun

      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, S, togglesplit, # dwindle

      # Move focus with mainMod + hjkl
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };
  programs.waybar = {
    enable = true;
    style = lib.fileContents ./waybar.css;
    settings = [{
    height = 30; # Waybar height (to be removed for auto height)
    spacing = 4; # Gaps between modules (4px)
    modules-left = ["wlr/workspaces" "hyprland/submap"];
    modules-center = ["hyprland/window"];
    modules-right = ["idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray"];
    "wlr/workspaces" = {
        all-outputs = true;
        active-only = true;
        format = "{name}: {icon}";
        format-icons = {
            "1" = "";
            "2" = "";
            "3" = " ";
            "4" = "";
            "5" = "";
            urgent = "";
            focused = "";
            default = "";
        };
    };
    "hyprland/window" = {
        separate-outputs = true;
    };
    "hyprland/submap" = {
        format = "<span style=\"italic\">{}</span>";
    };
    "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = ["" ""];
        tooltip = true;
        tooltip-format = "{app}: {title}";
    };
    idle_inhibitor = {
        format = "{icon}";
        format-icons = {
            activated = "";
            deactivated = "";
        };
    };
    tray = {
        # icon-size = 21;
        spacing = 10;
    };
    clock = {
        # timezone = "America/New_York";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = "{:%Y-%m-%d}";
    };
    cpu = {
        format = "{usage}% ";
        tooltip = false;
    };
    memory = {
        format = "{}% ";
    };
    temperature = {
        # thermal-zone = 2;
        # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        # format-critical = "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" ""];
    };
    backlight = {
        # device = "acpi_video1";
        format = "{percent}% {icon}";
        format-icons = ["" "" "" "" "" "" "" "" ""];
    };
    battery = {
        states = {
            # good = 95;
            warning = 30;
            critical = 15;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        # format-good = ""; # An empty format will hide the module
        # format-full = "";
        format-icons = ["" "" "" "" ""];
    };
    network = {
        # interface = "wlp2*"; # (Optional) To force the use of this interface
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
    };
    pulseaudio = {
        # scroll-step = 1; # %, can be a float
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
        };
        on-click = "pavucontrol";
    };
    }];
  };
}
