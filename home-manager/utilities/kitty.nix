# home-manager/utilities/kitty.nix
# Kitty terminal configuration
{
  config,
  lib,
  pkgs,
  ...
}: let
  fonts = config.utils.fonts;
in {
  programs.kitty = {
    enable = true;
    font = {
      name = config.stylix.fonts.monospace.name;
      size = lib.mkForce fonts.monospace.size;
    };

    settings = {
      allow_remote_control = "socket-only";
      close_on_child_death = true;
      cursor_shape = "beam";
      enable_audio_bell = false;
      listen_on = "unix:${config.home.homeDirectory}/.local/share/kitty/kitty.sock";
      mouse_hide_wait = 0;
      scrollback_lines = 100000;
      strip_trailing_spaces = "always";
      touch_scroll_multiplier = 20;

      remember_window_size = false;
      initial_window_width = 1000;
      initial_window_height = 600;
    };

    keybindings = {
      "kitty_mod+b" = "launch --type overlay --stdin-source=@screen_scrollback hx";
      "kitty_mod+n" =
        if pkgs.stdenv.isLinux
        then "new_tab_with_cwd cglaunch kitty --detach"
        else "new_os_window_with_cwd";
      "kitty_mod+u" = ''launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(emoji-dmenu -k overlay)\e[201~"' '';
      "kitty_mod+г" = ''launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(emoji-dmenu -k overlay)\e[201~"' '';
      "kitty_mod+i" = ''launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(wl-clipboard-manager dmenu -k overlay)\e[201~"' '';
      "kitty_mod+ш" = ''launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(wl-clipboard-manager dmenu -k overlay)\e[201~"' '';
      "kitty_mod+0" = "change_font_size all 0";
      "kitty_mod+с" = "copy_to_clipboard";
      "kitty_mod+м" = "paste_from_clipboard";
    };
  };

  home.file.".local/share/kitty/.keep".text = "";

  home.packages = with pkgs; [
    # Packages for Kitty
    kitty-img
    kitty-themes
  ];
}
