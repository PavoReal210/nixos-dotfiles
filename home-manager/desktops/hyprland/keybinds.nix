{
  config,
  pkgs,
  ...
}: let
  terminal = "ghostty";
in {
  # ── Keybindings ────────────────────────────────────────────────────────────
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

  wayland.windowManager.hyprland.settings = {
    # Define the SUPER key variable so bind lines can reference $modifier.
    "$modifier" = "SUPER";

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
      "$modifier SHIFT, q, exec, hyprctl kill"

      # ── Layout Modes ──
      # stacking/tabbed → togglegroup
      "$modifier, s, togglegroup"
      "$modifier, w, lockactivegroup, toggle"
      "$modifier, e, layoutmsg, togglesplit"

      # ── App Launchers ──
      # Desktop-entry launcher: shows installable GUI apps, not every PATH binary.
      "$modifier, d, exec, desktop-launcher"
      "$modifier SHIFT, d, exec, window-switcher"
      "$modifier, t, exec, ${terminal}"
      "$modifier, Return, exec, ${terminal}"
      "$modifier, b, exec, ${pkgs.floorp-bin}/bin/floorp"
      "$modifier SHIFT, e, exec, ${pkgs.xfce.thunar}/bin/thunar"

      # ── Screenshot (grimshot works on Hyprland) ──
      # Print Screen — save full screen to ~/Pictures/Screenshots
      ", Print, exec, shot-full"
      # Super+Shift+S — save area selection to ~/Pictures/Screenshots and copy to clipboard
      "$modifier SHIFT, s, exec, shot-area"

      # ── Clipboard History ──
      "$modifier SHIFT, v, exec, cliphist list | bemenu-themed -l 20 | cliphist decode | wl-copy"

      # ── Lock & Power ──
      "$modifier, x, exec, ${pkgs.hyprlock}/bin/hyprlock"
      "$modifier SHIFT, x, exec, powermenu-bemenu"

      # ── VPN ──
      "CTRL ALT, p, exec, pia-selector"

      # ── Reload & Restart ──
      # Reload: hyprctl reload
      "$modifier SHIFT, c, exec, hyprctl reload"
      # Restart: Hyprland has no restart command — exit and let greetd relaunch
      # (back to the ReGreet login screen)
      "$modifier SHIFT, r, exec, hyprctl dispatch exit"

      # ── Custom App Launchers (Emacs, Anki, Emoji) ──
      "CTRL ALT, z, exec, emacsclient -c -a emacs"
      "CTRL ALT, e, exec, bemoji"
      "CTRL ALT, a, exec, anki"

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
  };
}
