# system/configuration.nix
# Main NixOS system configuration
{...}: {
  imports = [
    ./ananicy.nix
    ./audio.nix
    ./base-packages.nix
    ./bluetooth.nix
    ./boot.nix
    ./cpu-performance.nix
    ./default-desktop.nix
    ./desktop-manager.nix
    ./doas.nix
    ./file-management.nix
    ./filesystem.nix
    ./fonts.nix
    ./gaming.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./network.nix
    ./nix-settings.nix
    ./nvidia.nix
    ./printing.nix
    ./scheduler.nix
    ./secrets.nix
    ./stylix.nix
    ./suspend.nix
    ./users.nix
    ./vpn.nix
    ./zram.nix
  ];

  # System state version - do not change after initial install
  system.stateVersion = "25.11";
}
