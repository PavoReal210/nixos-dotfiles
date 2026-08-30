{...}: {
  # ── Layer Rules & Window Rules ─────────────────────────────────────────────
  # These use raw hyprlang syntax because the hyprlang parser can't
  # handle them as key-value pairs in the settings attrset.
  # EDIT: To add a window rule, copy a line and change the class/title.
  #       windowrulev2 = effect, class:^(regex)$[, title:^(regex)$][, floating:1]
  #       layerrule = effect, namespace
  wayland.windowManager.hyprland.extraConfig = ''
    # ── Layer Rules (Waybar blur) ──
    layerrule = blur, namespace:waybar
    layerrule = ignorealpha 0.01, namespace:waybar

    # ── Window Rules ──
    # Format: windowrulev2 = effect, matcher[, matcher...]
    # Matchers: class:regex, title:regex, floating:0/1, workspace:N, etc.

    # Center floating popup windows (save dialogs, settings, etc.)
    windowrulev2 = center, class:^(floorp)$, floating:1

    # Disable blur for transparent terminals and editors
    windowrulev2 = noblur, class:^(com\.mitchellh\.ghostty)$
    windowrulev2 = noblur, class:^(emacs)$

    # Floating apps
    windowrulev2 = float, class:^(Pavucontrol)$
    windowrulev2 = float, class:^(Blueman-manager)$
    windowrulev2 = float, class:^(Nm-connection-editor)$
    windowrulev2 = float, class:^(floating_term)$
    windowrulev2 = size 800 600, class:^(floating_term)$
    windowrulev2 = float, title:^(pop-up)$
    windowrulev2 = float, title:^(task_dialog)$

    # File Roller — float the archive manager so it opens as a normal window
    # instead of being tiled.
    windowrulev2 = float, class:^(org\.gnome\.FileRoller)$

    # Games launched by Steam use the steam_app_<appid> class under XWayland.
    # Keep them out of the tiling layout without forcing fullscreen.
    windowrulev2 = float, class:^(steam_app_[0-9]+)$

    # RetroArch — keep it out of the tiling layout and start it fullscreen.
    # Remove the fullscreen rule if a freely resizable floating window is preferred.
    windowrulev2 = float, class:^(com\.libretro\.RetroArch)$
    windowrulev2 = fullscreen, class:^(com\.libretro\.RetroArch)$

    # Workspace assigns
    windowrulev2 = workspace 4 silent, class:^(vlc)$
    windowrulev2 = workspace 5 silent, class:^(Strawberry)$
    windowrulev2 = workspace 6 silent, class:^(steam)$
    windowrulev2 = workspace 7 silent, class:^(org\.mozilla\.Thunderbird|[Tt]hunderbird)$
  '';
}
