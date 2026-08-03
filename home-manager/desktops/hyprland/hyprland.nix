{
  config,
  lib,
  ...
}: let
  c = config.lib.stylix.colors;
in {
  # ── Hyprland Compositor ───────────────────────────────────────────────────
  # Main Hyprland configuration.
  # Colors come from stylix (atelier-forest base16).
  # Every section has comments so you can manually edit the config.
  #
  # The Hyprland config is split across four files:
  #   hyprland.nix     — general settings (monitors, visuals, input, layout)
  #   keybinds.nix     — keybindings (bind/bindm, $modifier variable)
  #   exec-once.nix    — apps launched on Hyprland startup
  #   window-rules.nix — layer rules + window rules (extraConfig)
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
      # be expressed in the home-manager settings attrset. They use extraConfig
      # in window-rules.nix.

      # ── Default Workspace ──────────────────────────────────────────────────
      # Opens on workspace 1 by default.
      workspace = [
        "w[t1]f[1], gapsout:0, gapsin:0"
      ];
    };
  };
}
