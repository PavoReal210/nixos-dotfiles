# system/configuration.nix
# Main NixOS system configuration
{
  ...
}:
{
  imports = [
    ./audio.nix
    ./base-packages.nix
    ./bluetooth.nix
    ./boot.nix
    ./default-desktop.nix
    ./desktop-manager.nix
    ./fonts.nix
    ./gaming.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./network.nix
    ./nix-settings.nix
    ./nvidia.nix
    ./power-management.nix
    ./suspend.nix
    ./users.nix
    ./vpn.nix
  ];

  # System state version - do not change after initial install
  system.stateVersion = "25.11";
}
