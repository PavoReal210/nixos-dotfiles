# system/fonts.nix
# System-wide font configuration
{
  config,
  pkgs,
  ...
}: {
  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.hack
    nerd-fonts.proggy-clean-tt
    nerd-fonts.overpass
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    nerd-fonts.tinos
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-sans
    nerd-fonts.victor-mono
    nerd-fonts.terminess-ttf

    # Standard Fonts
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf

    # Document Fonts
    et-book
    scientifica

    # Special Purpose Fonts
    weather-icons
  ];
  fonts.fontconfig.allowBitmaps = true;
}
