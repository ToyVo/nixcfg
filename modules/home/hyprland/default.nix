{ pkgs, lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.hyprland.enable = lib.mkEnableOption "Enable hyprland" // {
    default = true;
  };

  config = lib.mkIf cfg.hyprland.enable {
    home.packages = with pkgs; [ cinnamon.nemo hyprpaper ];
    programs.wofi = {
      enable = true;
      settings = {
        mode = "drun";
        allow_images = true;
        image_size = 40;
        term = "wezterm";
        insensitive = true;
        location = "center";
        no_actions = true;
        prompt = "Search";
      };
      style = ''
        @define-color bg_dim #232a2e;
        @define-color bg0 #2d353b;
        @define-color bg1 #343f44;
        @define-color bg2 #3d484d;
        @define-color bg3 #475258;
        @define-color bg4 #4f585e;
        @define-color bg5 #56635f;
        @define-color bg_visual #543a48;
        @define-color bg_red #514045;
        @define-color bg_green #425047;
        @define-color bg_blue #3a515d;
        @define-color bg_yellow #4d4c43;
        @define-color fg #d3c6aa;
        @define-color red #e67e80;
        @define-color orange #e69875;
        @define-color yellow #dbbc7f;
        @define-color green #a7c080;
        @define-color aqua #83c092;
        @define-color blue #7fbbb3;
        @define-color purple #d699b6;
        @define-color grey0 #7a8478;
        @define-color grey1 #859289;
        @define-color grey2 #9da9a0;

        * {
            font-family: FiraCode Nerd Font, Font Awesome 6 Free;
            font-size: 16px;
            border-radius: 8px;
            border: none;
        }

        window {
            margin: 0px;
            background-color: @fg;
            color: @bg0;

        	  border-radius: 16px;

            border-bottom-width: 4px;
            border-bottom-color: #7d6a40;
            border-bottom-style: solid;
        }

        #outer-box {
            margin: 0px;
            border-radius: 0px;
        }

        #input {
            background-color: @green;
            color: @bg0;

            margin: 16px;
            padding: 8px;
            border: none;

            border-bottom-width: 4px;
            border-bottom-color: #556a35;
            border-bottom-style: solid;
        }

        #inner-box {
            margin: 24px;
            padding: 0px;
            border-radius: 0px;
            background-color: #00000000;
        }

        #scroll {
            margin: 0px;
            padding: 0px;
            border: none;
        }

        #text {
            margin-left: 16px;
            margin-right: 16px;
        }

        #entry {
            border: none;
            padding: 8px;
            margin: 0px;
        }

        #entry:selected {
            background-color: @bg0;
            color: @fg;

            border-bottom-width: 4px;
            border-bottom-color: #161a1d;
            border-bottom-style: solid;
        }
      '';
    };
    wayland.windowManager.hyprland = {
      enable = true;
      recommendedEnvironment = true;
      extraConfig = ''
        $bg_dim = 0xff232a2e
        $bg0 = 0xff2d353b
        $bg1 = 0xff343f44
        $bg2 = 0xff3d484d
        $bg3 = 0xff475258
        $bg4 = 0xff4f585e
        $bg5 = 0xff56635f
        $bg_visual = 0xff543a48
        $bg_red = 0xff514045
        $bg_green = 0xff425047
        $bg_blue = 0xff3a515d
        $bg_yellow = 0xff4d4c43
        $fg = 0xffd3c6aa
        $red = 0xffe67e80
        $orange = 0xffe69875
        $yellow = 0xffdbbc7f
        $green = 0xffa7c080
        $aqua = 0xff83c092
        $blue = 0xff7fbbb3
        $purple = 0xffd699b6
        $grey0 = 0xff7a8478
        $grey1 = 0xff859289
        $grey2 = 0xff9da9a0
        # Apply themes

        general {
            gaps_in = 10
            gaps_out = 20

            border_size = 4
            col.active_border = $fg
            col.inactive_border = $bg5

            layout = dwindle

            col.group_border = $fg
            col.group_border_active = $bg5

            resize_on_border = true
        }

        decoration {
            rounding = 10

            blur = no
            blur_size = 3
            blur_passes = 4
            blur_new_optimizations = on
            blur_xray = true
            blur_ignore_opacity = true

            drop_shadow = yes
            shadow_range = 0
            shadow_render_power = 4
            col.shadow = rgb(7d6a40)
            col.shadow_inactive = rgb(2b312f)
            shadow_scale = 1.0
            shadow_offset = 0 10

            dim_inactive = false
            dim_strength = 0.1

            dim_around = 0.0

            multisample_edges = true
        }

        animations {
            enabled = yes

            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            bezier = myBezier2, 0.65, 0, 0.35, 1
            bezier = linear, 0, 0, 1, 1

            bezier=slow,0,0.85,0.3,1
            bezier=overshot,0.7,0.6,0.1,1.1
            bezier=bounce,1,1.6,0.1,0.85
            bezier=slingshot,1,-1,0.15,1.25
            bezier=nice,0,6.9,0.5,-4.20

            animation = windows,1,5,bounce,popin
            animation = border,1,20,default
            animation = fade, 1, 5, overshot
            animation = workspaces, 1, 6, overshot, slidevert
            animation = windowsIn,1,5,slow,popin
            animation = windowsMove,1,5,default
        }

        dwindle {
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = yes # you probably want this
        }

        $mainMod = SUPER

        exec-once = waybar & hyprpaper & firefox
        bind = $mainMod, SPACE, exec, wofi --show drun
        bind = $mainMod, V, togglefloating,
        bind = $mainMod, S, togglesplit, # dwindle

        # Wofi menus
        bind = $mainMod, D, exec, pkill wofi || wofi --show drun --term=wezterm --width=35% --height=50% --columns 1 -I
        bind = $mainMod, V, exec, pkill wofi || cliphist list | wofi --dmenu | cliphist decode | wl-copy

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e-1
        bind = $mainMod, mouse_up, workspace, e+1

        # Resize focused window with arrow keys, indicated with borders of a different color
        bind = $mainMod, R, exec, hyprctl --batch keyword "general:col.active_border rgba(bf616aff);"
        bind = $mainMod, R, exec, hyprctl --batch keyword "general:col.group_border_active rgba(bf616aff);"
        bind = $mainMod, R, submap, resize
        submap = resize
        binde = , right, resizeactive, 15 0
        binde = , left, resizeactive, -15 0
        binde = , up, resizeactive, 0 -15
        binde = , down, resizeactive, 0 15
        bind = , escape, exec, hyprctl --batch keyword "general:col.active_border rgba(8fbcbbff);"
        bind = , escape, exec, hyprctl --batch keyword "general:col.group_border_active rgba(8fbcbbff);"
        bind = , escape, submap, reset
        submap = reset
        # Environement variables
        env = HYPRLAND_LOG_WLR, 1
        env = _JAVA_AWT_WM_NONREPARENTING, 1
        env = WLR_NO_HARDWARE_CURSORS, 1
        env = XDG_SESSION_TYPE, wayland
        env = MOZ_ENABLE_WAYLAND,1
        env = QT_QPA_PLATFORMTHEME, qt5ct
        env = LIBVA_DRIVER_NAME, nvidia
        env = GBM_BACKEND, nvidia-drm
        env = GDK_BACKEND, wayland,x11

        monitor=,preferred,auto,1

        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

        # Startup programs and scipts
        exec-once = ckb-next -b
        exec-once = hyprctl setcursor Bibata-Modern-Classic 24
        exec-once = /usr/lib/polkit-kde-authentication-agent-1
        exec-once = wl-paste --type text --watch cliphist store #Stores only text data
        exec-once = wl-paste --type image --watch cliphist store #Stores only image data
        # exec = eww daemon
        exec-once = sleep 3 && /usr/lib/kdeconnectd

        general {
            cursor_inactive_timeout = 0
        }

        input {
            kb_layout = us
            kb_variant = multix
            kb_model =
            kb_options = ctrl:nocaps
            kb_rules =
            numlock_by_default=true

            follow_mouse = 1

            touchpad {
                natural_scroll = yes
            }

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }

        gestures {
            workspace_swipe=1
            workspace_swipe_distance=400
            workspace_swipe_invert=1
            workspace_swipe_min_speed_to_force=30
            workspace_swipe_cancel_ratio=0.5
            workspace_swipe_create_new=0
            workspace_swipe_forever=1
        }

        master {
            new_is_master = true
        }

        gestures {
            workspace_swipe = on
        }

        device:epic mouse V1 {
            sensitivity = -0.5
        }

        binds {
        	workspace_back_and_forth = true

        }

        misc {
        	layers_hog_keyboard_focus = true
            focus_on_activate = true
        }

        layerrule = noanim,selection

        windowrule = maxsize 600 800, ^(pavucontrol)$
        windowrule = center, ^(pavucontrol)$
        windowrule = float, ^(pavucontrol)$
        windowrule = tile, ^(libreoffice)$
        windowrule = float, ^(blueman-manager)$
        windowrule = nofullscreenrequest, ^(.*libreoffice.*)$
        windowrule = size 490 600, ^(org.gnome.Calculator)$
        windowrule = float, ^(org.gnome.Calculator)$
        windowrule = float, ^(org.kde.polkit-kde-authentication-agent-1)$
        windowrule = float, title:^(Confirm to replace files)$
        windowrule = float, title:^(File Operation Progress)$

        windowrule = center, ^(eog)$
        windowrule = center, ^(vlc)$
        windowrule = float, ^(eog)$
        windowrule = float, ^(vlc)$
        windowrule = float, ^(imv)$
        windowrule = float, title:^(Steam - News)$

        # Main binds
        bind = $mainMod, return, exec, wezterm
        bind = $mainMod, Q, killactive,
        bind = $mainMod, M, exit,
        bind = $mainMod, E, exec, nemo
        bind = $mainMod, G, togglegroup
        bind = $mainMod SHIFT, G, moveoutofgroup
        bind = $mainMod CTRL, G, moveintogroup, r
        bind = $mainMod, F, fullscreen,
        bind = $mainMod, A, movetoworkspace, special
        bind = SUPER_SHIFT, R, exec, hyprctl reload
        bind = $mainMod, P, pseudo, # dwindle
        bind = $mainMod, W, exec, eww open --toggle overview  && eww update selected=_none
        bind = $mainMod, O, exec, grim -g "$(slurp)" "tmp.png" && tesseract "tmp.png" - | wl-copy && rm "tmp.png"
        bind = $mainMod, N, exec, swaync-client -t
        bind = $mainMod, U, layoutmsg, swapwithmaster
        bind = ALT, F10, pass, ^(com\.obsproject\.Studio)$
        bind = ALT, Tab, focuscurrentorlast


        # Hardware controls using function keys
        bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-
        bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%

        binde = , XF86AudioRaiseVolume, exec, pactl -- set-sink-volume @DEFAULT_SINK@ +5%
        binde = , XF86AudioRaiseVolume, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

        binde = , XF86AudioLowerVolume, exec, pactl -- set-sink-volume @DEFAULT_SINK@ -5%
        binde = , XF86AudioLowerVolume, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

        bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
        bind = , XF86AudioMute, exec, sh /home/mathis_hyprland/.config/hypr/scripts/notify-volume.sh

        # Toggle gaps
        bind = $mainMod, H, exec, sh .config/hypr/scripts/toggle-gaps.sh

        # Toggle between floating windows
        #bind = ALT, Tab, cyclenext,
        #bind = ALT, Tab, bringactivetotop,

        bind = $mainMod, Tab, changegroupactive,

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, MINUS, workspace, special
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

        bind = $mainMod CTRL, 1, movetoworkspacesilent, 1
        bind = $mainMod CTRL, 2, movetoworkspacesilent, 2
        bind = $mainMod CTRL, 3, movetoworkspacesilent, 3
        bind = $mainMod CTRL, 4, movetoworkspacesilent, 4
        bind = $mainMod CTRL, 5, movetoworkspacesilent, 5
        bind = $mainMod CTRL, 6, movetoworkspacesilent, 6
        bind = $mainMod CTRL, 7, movetoworkspacesilent, 7
        bind = $mainMod CTRL, 8, movetoworkspacesilent, 8
        bind = $mainMod CTRL, 9, movetoworkspacesilent, 9
        bind = $mainMod CTRL, 0, movetoworkspacesilent, 10

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        bind = $mainMod SHIFT, left, movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r
        bind = $mainMod SHIFT, up, movewindow, u
        bind = $mainMod SHIFT, down, movewindow, d

        bind = $mainMod CTRL, left, workspace, e-1
        bind = $mainMod CTRL, right, workspace, e+1

        bindl = , XF86AudioPlay, exec, playerctl play-pause
        bindl = , XF86AudioPrev, exec, playerctl previous
        bindl = , XF86AudioNext, exec, playerctl next
      '';
    };
    programs.waybar = {
      enable = true;
      settings = [{
        margin-top = 0;
        margin-left = 120;
        margin-bottom = 0;
        margin-right = 120;
        height = 60;
        layer = "top";
        position = "top";
        output = "";
        spacing = 16;
        modules-left = [ "custom/launcher" "clock" "clock#date" ];
        modules-center = [ "wlr/workspaces" ];
        modules-right = [ "pulseaudio" "network" "battery" "custom/powermenu" ];

        "wlr/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          "persistent_workspaces" = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
            "7" = [ ];
            "8" = [ ];
            "9" = [ ];
            "10" = [ ];
          };
        };

        "custom/launcher" = {
          interval = "once";
          format = "󰣇";
          on-click =
            "pkill wofi || wofi --show drun --term=wezterm --width=20% --height=50% --columns 1 -I";
          tooltip = false;
        };

        backlight = {
          device = "nvidia_0";
          max-length = "4";
          format = "{icon}";
          tooltip-format = "{percent}%";
          format-icons = [ "" "" "" "" "" "" "" ];
          on-click = "";
          on-scroll-up = "brightnessctl set 10%-";
          on-scroll-down = "brightnessctl set +10%";
        };

        memory = {
          interval = 30;
          format = "  {}%";
          format-alt = " {used:0.1f}G";
          max-length = 10;
        };

        "custom/dunst" = {
          on-click = "dunstctl set-paused toggle";
          restart-interval = 1;
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon}  {volume}%";
          format-bluetooth-muted = "婢  muted";
          format-muted = "婢 muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click-right = "pavucontrol";
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = " {signalStrength}%";
          format-disconnected = "󰤭";
        };

        battery = {
          bat = "BAT0";
          adapter = "ADP0";
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          max-length = 10;
          format = "{icon} {capacity}%";
          format-warning = "{icon} {capacity}%";
          format-critical = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{icon} {capacity}%";
          format-full = " 100%";
          format-icons = [ "" "" "" "" "" "" "" "" "" "" ];
        };

        clock = { format = " {:%H:%M}"; };

        "clock#date" = { format = " {:%A, %B %d, %Y}"; };

        "custom/powermenu" = {
          format = "";
          on-click =
            "pkill wofi || sh .config/wofi/scripts/powermenu.sh 'gruvbox-light' '--height=17% -o $MAIN_DISPLAY'";
          tooltip = false;
        };
      }];
      style = ''
        @define-color bg_dim #232a2e;
        @define-color bg0 #2d353b;
        @define-color bg1 #343f44;
        @define-color bg2 #3d484d;
        @define-color bg3 #475258;
        @define-color bg4 #4f585e;
        @define-color bg5 #56635f;
        @define-color bg_visual #543a48;
        @define-color bg_red #514045;
        @define-color bg_green #425047;
        @define-color bg_blue #3a515d;
        @define-color bg_yellow #4d4c43;
        @define-color fg #d3c6aa;
        @define-color red #e67e80;
        @define-color orange #e69875;
        @define-color yellow #dbbc7f;
        @define-color green #a7c080;
        @define-color aqua #83c092;
        @define-color blue #7fbbb3;
        @define-color purple #d699b6;
        @define-color grey0 #7a8478;
        @define-color grey1 #859289;
        @define-color grey2 #9da9a0;

        * {
          font-family: FiraCode Nerd Font, Font Awesome 6 Free;
          font-size: 16px;
          font-weight: bold;
        }

        window#waybar {
          background-color: @fg;
          color: @bg0;
          transition-property: background-color;
          transition-duration: 0.5s;
          border-radius: 0px 0px 16px 16px;
          transition-duration: .5s;

          border-bottom-width: 4px;
          border-bottom-color: #7d6a40;
          border-bottom-style: solid;
        }

        #custom-launcher,
        #clock,
        #clock-date,
        #workspaces,
        #pulseaudio,
        #network,
        #battery,
        #custom-powermenu {
          background-color: @bg0;
          color: @fg;

          padding-left: 8px;
          padding-right: 8px;
          margin-top: 8px;
          margin-bottom: 12px;
        	border-radius: 8px;

          border-bottom-width: 4px;
          border-bottom-color: #161a1d;
          border-bottom-style: solid;
        }

        #workspaces {
          padding: 0px;
        }

        #workspaces button.active {
          background-color: @blue;
          color: @bg0;

        	border-radius: 8px;

          margin-bottom: -4px;

          border-bottom-width: 4px;
          border-bottom-color: #366660;
          border-bottom-style: solid;
        }

        #custom-launcher {
          background-color: @green;
          color: @bg0;
          border-bottom-color: #556a35;

          margin-left: 16px;
          padding-left: 24px;
          padding-right: 24px;
        }

        #custom-powermenu {
          background-color: @red;
          color: @bg0;
          border-bottom-color: #951c1f;

          margin-right: 16px;
          padding-left: 24px;
          padding-right: 24px;
        }
      '';
    };
  };
}
