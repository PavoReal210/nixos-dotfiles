{
  config,
  lib,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors;

  # Waybar uses 18px labels. Bemenu needs a slightly larger explicit size for
  # readable text on this display, so use 20px for the menu font.
  bemenuFont = config.utils.fonts.status // {size = 20;};

  # Pass the complete palette directly on the command line. This avoids relying
  # on BEMENU_OPTS being parsed consistently across shell and Hyprland sessions.
  bemenuArgs = lib.escapeShellArgs [
    "--ab"
    "#${c.base00}"
    "--af"
    "#${c.base05}"
    "--bdr"
    "#${c.base0D}"
    "--cb"
    "#${c.base0D}"
    "--cf"
    "#${c.base00}"
    "--fb"
    "#${c.base00}"
    "--fbb"
    "#${c.base0D}"
    "--fbf"
    "#${c.base00}"
    "--ff"
    "#${c.base05}"
    "--fn"
    (config.utils.fonts.describeFont bemenuFont)
    "--hb"
    "#${c.base0D}"
    "--hf"
    "#${c.base00}"
    "--nb"
    "#${c.base00}"
    "--nf"
    "#${c.base05}"
    "--sb"
    "#${c.base0D}"
    "--scb"
    "#${c.base01}"
    "--scf"
    "#${c.base05}"
    "--sf"
    "#${c.base00}"
    "--tb"
    "#${c.base00}"
    "--tf"
    "#${c.base0D}"
  ];

  bemenu = pkgs.writeShellScriptBin "bemenu-themed" ''
    exec ${pkgs.bemenu}/bin/bemenu ${bemenuArgs} "$@"
  '';

  bemenuRun = pkgs.writeShellScriptBin "bemenu-themed-run" ''
    exec ${pkgs.bemenu}/bin/bemenu-run ${bemenuArgs} "$@"
  '';

  # j4-dmenu-desktop reads .desktop files instead of scanning every executable
  # in PATH, giving Bemenu the same application set as Rofi's drun mode.
  desktopLauncher = pkgs.writeShellScriptBin "desktop-launcher" ''
    exec ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop \
      --dmenu="bemenu-themed" \
      --no-generic \
      --case-insensitive \
      --term-mode custom \
      --term "ghostty -e {cmdline@}"
  '';
in {
  programs.bemenu.enable = true;

  home.packages = with pkgs; [
    bemenu
    bemenuRun
    bemoji
    desktopLauncher
    j4-dmenu-desktop
  ];
}
