{pkgs, ...}: {
  # ── Startup Applications ───────────────────────────────────────────────
  # exec-once = runs only once at Hyprland start
  # exec = runs on every config reload
  #
  # EDIT: Add/remove startup apps here. To add a new app:
  #   exec-once = /path/to/your/app
  wayland.windowManager.hyprland.settings = {
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
  };
}
