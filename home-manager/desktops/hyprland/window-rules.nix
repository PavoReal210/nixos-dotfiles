{...}: {
  # ── Layer Rules & Window Rules ─────────────────────────────────────────────
  # These use raw hyprlang syntax because the hyprlang parser (0.6.8) can't
  # handle them as key-value pairs in the settings attrset.
  # EDIT: To add a window rule, copy a line and change the class/title.
  #       To add a layer rule, use: layerrule = effect, match:namespace <name>
  wayland.windowManager.hyprland.extraConfig = ''
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

    # Games launched by Steam use the steam_app_<appid> class under XWayland.
    # Keep them out of the tiling layout without forcing fullscreen.
    windowrule {
      name = steam-game-float
      match:class = ^(steam_app_[0-9]+)$
      float = true
    }

    # RetroArch — keep it out of the tiling layout and start it fullscreen.
    # Remove `fullscreen` if a freely resizable floating window is preferred.
    windowrule {
      name = retroarch-fullscreen
      match:class = ^(com\\.libretro\\.RetroArch)$
      float = true
      fullscreen = 1
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
      match:class = ^(org\\.mozilla\\.Thunderbird|[Tt]hunderbird)$
      workspace = 7 silent
    }
  '';
}
