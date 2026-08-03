{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  terminal = "ghostty";
  bemenu-cmd = "${pkgs.bemenu}/bin/bemenu-run";
in
{
  # ── Hyprland Compositor ───────────────────────────────────────────────────
  # Main Hyprland configuration.
  # Colors come from stylix (atelier-forest base16).
  # Every section has comments so you can manually edit the config.
  #
  # TO ADD A NEW KEYBINDING:
  #   1. Find the relevant section below (keybindings, exec, etc.)
  #   2. Add a line like: bind = $modifier, key, dispatcher, args
  #   3. Common dispatchers: exec, killactive, togglefloating, fullscreen, workspace, movetoworkspace
  #
  # TO CHANGE COLORS:
  #   Edit the color variables at the top of this file or in the decoration/general sections.
  #   They reference config.lib.stylix.colors.base0X — the atelier-forest palette.

  wayland.windowManager.hyprland = {
    enable = true;

    # Keep using the hyprlang config syntax.
    # home-manager's default for `configType` changed from "hyprlang" to "lua"
    # (for stateVersion >= 26.05). We pin "hyprlang" so the `settings` block
    # below keeps working exactly as written, and to silence the eval warning.
    configType = "hyprlang";

    settings = {
      # Define the SUPER key variable so bind lines can reference $modifier.
      "$modifier" = "SUPER";

      # ── Monitor / Scaling ──────────────────────────────────────────────────
      # Fractional scaling at 1.6.
      # Format: name, resolution, position, scale
      # EDIT: Change "1.6" to adjust scaling. Use "1" for no scaling.
      monitor = ", preferred, auto, 1.6";

      xwayland = {
        force_zero_scaling = true;
      };

      # ── General ────────────────────────────────────────────────────────────
      # Core compositor settings: gaps, borders, layout, focus behavior.
      # EDIT: Change gaps_in/gaps_out for spacing, border_size for window borders.
      # mkForce overrides stylix's auto-generated border colors so we can use
      # the gradient format (two colors = gradient across the border).
      general = lib.mapAttrs (_: lib.mkForce) {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 3;
        "col.active_border" = "rgb(${c.base0D}) rgb(${c.base0D})";
        "col.inactive_border" = "rgb(${c.base02})";
        layout = "dwindle";
        allow_tearing = false;
      };

      # ── Decoration ─────────────────────────────────────────────────────────
      # Window decorations, blur, shadows, rounding.
      # EDIT: Change rounding for more/less round corners. Change blur passes/radius.
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 7;
          passes = 4;
          noise = 0.02;
          contrast = 1;
          brightness = 1;
          vibrancy = 1;
          vibrancy_darkness = 1;
          new_optimizations = true;
          xray = false;
          popups = true;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = lib.mkForce "rgba(${c.base00}ee)";
        };
      };

      # ── Animations ─────────────────────────────────────────────────────────
      # Window/workspace animations. Default set is subtle.
      # EDIT: Change bezier curves or animation durations to taste.
      animations = {
        enabled = true;
        bezier = "easeInOutExpo, 0.87, 0, 0.13, 1";
        animation = [
          "windows, 1, 5, easeInOutExpo"
          "windowsOut, 1, 5, easeInOutExpo, popin 80%"
          "border, 1, 8, default"
          "borderangle, 1, 8, default"
          "fade, 1, 5, default"
          "workspaces, 1, 6, default, slidefade 30%" # Slide fade gives you a cool slide effect
        ];
      };

      # ── Dwindle Layout ─────────────────────────────────────────────────────
      # Dwindle is Hyprland's default tiling layout.
      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      # ── Input ──────────────────────────────────────────────────────────────
      # Keyboard layout and mouse settings.
      # EDIT: Change xkb_layout to add/remove keyboard layouts.
      input = {
        kb_layout = "us,latam";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      # ── Misc ───────────────────────────────────────────────────────────────
      # Various compositor misc options.
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # NOTE: layerrule and windowrule are special hyprlang keywords that can't
      # be expressed in the home-manager settings attrset. They use extraConfig below.

      # ── Keybindings ────────────────────────────────────────────────────────
      # Format: bind = MODS, KEY, DISPATCHER, ARGS
      # MODS: SUPER, SHIFT, CTRL, ALT (can combine with ,)
      #
      # Common dispatchers:
      #   exec                  — run a command
      #   killactive            — close focused window
      #   togglefloating        — toggle floating state
      #   fullscreen, 0         — toggle fullscreen (0=toggle, 1=maximize, 2=fakefullscreen)
      #   workspace, N          — switch to workspace N
      #   movetoworkspace, N    — move window to workspace N
      #   movefocus, l/r/u/d    — move focus in direction
      #   movewindow, l/r/u/d   — move window in direction
      #   togglesplit           — toggle split direction in dwindle
      #   togglegroup           — group/ungroup windows
      #   exit                  — quit Hyprland
      #
      # To add a new keybind, copy an existing line and modify it.

      # ── Window Focus (vim-style) ──
      bind = [
        "$modifier, j, movefocus, l"
        "$modifier, k, movefocus, d"
        "$modifier, l, movefocus, u"
        "$modifier, semicolon, movefocus, r"

        # ── Window Move ──
        "$modifier SHIFT, j, movewindow, l"
        "$modifier SHIFT, k, movewindow, d"
        "$modifier SHIFT, l, movewindow, u"
        "$modifier SHIFT, semicolon, movewindow, r"

        # ── Layout Controls ──
        # splith/splitv → layoutmsg togglesplit (Hyprland 0.54+ requires layoutmsg prefix)
        "$modifier, h, layoutmsg, togglesplit"
        "$modifier, v, layoutmsg, togglesplit"
        "$modifier, f, fullscreen, 0"
        "$modifier, space, togglefloating"
        "$modifier SHIFT, space, focusurgentorlast"
        "$modifier, q, killactive"

        # ── Layout Modes ──
        # stacking/tabbed → togglegroup
        "$modifier, s, togglegroup"
        "$modifier, w, lockactivegroup, toggle"
        "$modifier, e, layoutmsg, togglesplit"

        # ── App Launchers ──
        "$modifier, d, exec, ${bemenu-cmd}"
        "$modifier SHIFT, d, exec, window-switcher"
        "$modifier, t, exec, ${terminal}"
        "$modifier, Return, exec, ${terminal}"
        "$modifier, b, exec, ${pkgs.floorp-bin}/bin/floorp"
        "$modifier SHIFT, e, exec, ${pkgs.thunar}/bin/thunar"

        # ── Screenshot (grimshot works on Hyprland) ──
        # Print Screen — save full screen to ~/Pictures/Screenshots
        ", Print, exec, shot-full"
        # Super+Shift+S — save area selection to ~/Pictures/Screenshots and copy to clipboard
        "$modifier SHIFT, s, exec, shot-area"

        # ── Clipboard History ──
        "$modifier SHIFT, v, exec, cliphist list | ${pkgs.bemenu}/bin/bemenu -l 20 | cliphist decode | wl-copy"

        # ── Lock & Power ──
        "$modifier, x, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "$modifier SHIFT, x, exec, powermenu-bemenu"

        # ── VPN ──
        "CTRL ALT, p, exec, pia-selector"

        # ── Reload & Restart ──
        # Reload: hyprctl reload
        "$modifier SHIFT, c, exec, hyprctl reload"
        # Restart: Hyprland has no restart command — exit and let SDDM relaunch
        "$modifier SHIFT, r, exec, hyprctl dispatch exit"

        # ── Custom App Launchers (Emacs, Anki, Emoji) ──
        "CTRL ALT, z, exec, emacsclient -c -a emacs"
        "CTRL ALT, e, exec, bemoji"
        "CTRL ALT, a, exec, ${pkgs.anki-bin}/bin/anki"

        # ── Workspace Switching ──
        "$modifier, 1, workspace, 1"
        "$modifier, 2, workspace, 2"
        "$modifier, 3, workspace, 3"
        "$modifier, 4, workspace, 4"
        "$modifier, 5, workspace, 5"
        "$modifier, 6, workspace, 6"
        "$modifier, 7, workspace, 7"
        "$modifier, 8, workspace, 8"
        "$modifier, 9, workspace, 9"
        "$modifier, 0, workspace, 10"

        # ── Move to Workspace ──
        "$modifier SHIFT, 1, movetoworkspace, 1"
        "$modifier SHIFT, 2, movetoworkspace, 2"
        "$modifier SHIFT, 3, movetoworkspace, 3"
        "$modifier SHIFT, 4, movetoworkspace, 4"
        "$modifier SHIFT, 5, movetoworkspace, 5"
        "$modifier SHIFT, 6, movetoworkspace, 6"
        "$modifier SHIFT, 7, movetoworkspace, 7"
        "$modifier SHIFT, 8, movetoworkspace, 8"
        "$modifier SHIFT, 9, movetoworkspace, 9"
        "$modifier SHIFT, 0, movetoworkspace, 10"

        # ── Next/Prev Workspace ──
        "$modifier, Tab, workspace, +1"
        "$modifier SHIFT, Tab, workspace, -1"
        "$modifier, bracketright, workspace, +1"
        "$modifier, bracketleft, workspace, -1"

        # ── Media Keys ──
        ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
        ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
        ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"

        # ── Brightness Keys ──
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
      ];

      # ── Mouse Bindings ──
      bindm = [
        "$modifier, mouse:272, movewindow"
        "$modifier, mouse:273, resizewindow"
      ];

      # ── Startup Applications ───────────────────────────────────────────────
      # exec-once = runs only once at Hyprland start
      # exec = runs on every config reload
      #
      # EDIT: Add/remove startup apps here. To add a new app:
      #   exec-once = /path/to/your/app
      exec-once = [
        # Wallpaper is now managed by stylix (stylix.image in theming/stylix.nix).
        # stylix will set the wallpaper and auto-generate a base16 color scheme from it.
        # "${pkgs.awww}/bin/awww-daemon"
        # "${pkgs.waypaper}/bin/waypaper --restore"

        # Dropbox client
        "${pkgs.maestral}/bin/maestral start"

        # Status bar (waybar auto-detects hyprland)
        "${pkgs.waybar}/bin/waybar"

        # Notification daemon
        "${pkgs.dunst}/bin/dunst"

        # Media player daemon (for waybar mpris module)
        "${pkgs.playerctl}/bin/playerctld daemon"

        # Idle inhibitors
        "${pkgs.wljoywake}/bin/wljoywake -t 10" # Inhibit idle on gamepad input
        "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit" # Inhibit idle on media playback

        # Polkit auth agent (required for pkexec prompts, e.g. gparted)
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      # ── Default Workspace ──────────────────────────────────────────────────
      # Opens on workspace 1 by default.
      workspace = [
        "w[t1]f[1], gapsout:0, gapsin:0"
      ];
    };

    # ── Layer Rules & Window Rules ─────────────────────────────────────────────
    # These use raw hyprlang syntax because the hyprlang parser (0.6.8) can't
    # handle them as key-value pairs in the settings attrset.
    # EDIT: To add a window rule, copy a line and change the class/title.
    #       To add a layer rule, use: layerrule = effect, match:namespace <name>
    extraConfig = ''
      # ── Layer Rules (Waybar blur) ──
      # Blur behind waybar.
      # Block format: layerrule { name = ..., match:namespace = ..., effect = value }
      layerrule {
        name = waybar-blur
        match:namespace = waybar
        blur = true
        ignore_alpha = 0.01
      }

      # ── Window Rules ──
      # Block format: windowrule { name = ..., match:property = value, effect = value }
      # Match props: class, title, initialClass, initialTitle, workspace, float, etc.
      # Effects: float, size, workspace, opacity, blur, noanim, border_size, etc.

      # Center floating popup windows (save dialogs, settings, etc.)
      windowrule {
        name = floorp-popup-center
        match:class = ^(floorp)$
        match:float = true
        center = 1
      }

      # Disable blur for transparent terminals and editors
      windowrule {
        name = ghostty-no-blur
        match:class = ^(com\\.mitchellh\\.ghostty)$
        no_blur = true
      }
      windowrule {
        name = emacs-no-blur
        match:class = ^(emacs)$
        no_blur = true
      }

      # Floating apps
      windowrule {
        name = pavucontrol-float
        match:class = ^(Pavucontrol)$
        float = true
      }
      windowrule {
        name = blueman-float
        match:class = ^(Blueman-manager)$
        float = true
      }
      windowrule {
        name = nm-editor-float
        match:class = ^(Nm-connection-editor)$
        float = true
      }
      windowrule {
        name = floating-term
        match:class = ^(floating_term)$
        float = true
        size = 800 600
      }
      windowrule {
        name = popup-float
        match:title = ^(pop-up)$
        float = true
      }
      windowrule {
        name = task-dialog-float
        match:title = ^(task_dialog)$
        float = true
      }

      # File Roller — float the archive manager so it opens as a normal window
      # instead of being tiled.
      windowrule {
        name = file-roller-float
        match:class = ^(org\\.gnome\\.FileRoller)$
        float = true
      }

      # RetroArch — float it so the window is freely resizable and the tiling
      # layout rules don't apply to it.
      windowrule {
        name = retroarch-float
        match:class = ^(com\\.libretro\\.RetroArch)$
        float = true
      }

      # Workspace assigns
      windowrule {
        name = vlc-ws4
        match:class = ^(vlc)$
        workspace = 4 silent
      }
      windowrule {
        name = strawberry-ws5
        match:class = ^(Strawberry)$
        workspace = 5 silent
      }
      windowrule {
        name = steam-ws6
        match:class = ^(steam)$
        workspace = 6 silent
      }
      windowrule {
        name = thunderbird-ws7
        match:class = ^(org\\.mozilla\\.Thunderbird|Thunderbird)$
        workspace = 7 silent
      }
    '';
  };
}
