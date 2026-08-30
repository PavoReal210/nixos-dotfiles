# system/base-packages.nix
# System-wide packages available to all users
# (Unfree/insecure package policy lives in system/nix-settings.nix;
#  Steam is fully configured in system/gaming.nix.)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Core utilities
    home-manager
    file
    wget
    curl
    git
    htop
    btop
    tree
    ntfs3g

    # LaTeX rendering (needed by Anki for traditional [latex]...[/latex] cards)
    texliveFull

    # Text editors
    vim

    # Terminal
    bash

    # Secure Boot
    sbctl

    # Secrets management
    sops
    age
    gnupg

    # JSON/YAML utilities
    jq
    yq
    moreutils

    # Nix utilities
    nurl
    alejandra
    nh
    nixd

    # Archive tools
    p7zip
    unzip
    zip

    # System monitoring
    lm_sensors
    pciutils
    usbutils

    # Base16 color schemes
    base16-schemes
  ];
}
