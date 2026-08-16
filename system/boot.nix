# system/boot.nix
# Bootloader configuration with Lanzaboote for Secure Boot
{pkgs, ...}: {
  # Lanzaboote enables systemd-boot internally; we just set options here
  boot.loader.systemd-boot = {
    consoleMode = "max";
  };

  # Enable Lanzaboote for Secure Boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # linux-zen 7.1.2 ships headers that removed linux/of_gpio.h, which
  # NVIDIA driver 580.142 still unconditionally includes. The default
  # kernel is tested against the nvidia driver in the same nixpkgs
  # release; use it until nvidia catches up.
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  # Loader settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
}
