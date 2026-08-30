# home-manager/utilities/ghostty.nix
# Ghostty terminal configuration
{config, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      font-family = "${config.stylix.fonts.monospace.name}";
      font-size = 14;

      background-opacity = 0.6; # 0.0 = fully transparent, 1.0 = fully opaque;
      background-blur = false;

      window-padding-x = 10;
      window-padding-y = 10;
      window-decoration = false;

      shell-integration = "zsh";

      clipboard-read = "allow";
      clipboard-write = "allow";

      mouse-hide-while-typing = true;

      scrollback-limit = 100000;

      palette = [
        "0=#${config.lib.stylix.colors.base01}"
        "1=#${config.lib.stylix.colors.base02}"
        "2=#${config.lib.stylix.colors.base03}"
        "3=#${config.lib.stylix.colors.base04}"
        "4=#${config.lib.stylix.colors.base05}"
        "5=#${config.lib.stylix.colors.base06}"
        "6=#${config.lib.stylix.colors.base07}"
        "7=#${config.lib.stylix.colors.base08}"
        "8=#${config.lib.stylix.colors.base09}"
        "9=#${config.lib.stylix.colors.base0A}"
        "10=#${config.lib.stylix.colors.base0B}"
        "11=#${config.lib.stylix.colors.base0C}"
        "12=#${config.lib.stylix.colors.base0D}"
        "13=#${config.lib.stylix.colors.base0E}"
        "14=#${config.lib.stylix.colors.base0F}"
        "15=#${config.lib.stylix.colors.base05}"
      ];
    };
  };
}
