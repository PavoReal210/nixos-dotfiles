# system/printing.nix
# Wi-Fi printing through CUPS with Avahi discovery.
#
# The printer itself is not hard-coded here because network printers can use
# DHCP addresses and most modern printers support driverless IPP Everywhere.
# Add a hardware.printers.ensurePrinters entry here later if a stable URI and
# model-specific configuration are needed.
{pkgs, ...}: {
  # Advertise and discover printers on the local network through mDNS.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;

    # cups-browsed discovers network printers advertised by Avahi. The
    # cups-filters package provides the driverless IPP filter stack.
    browsed.enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed

      # HPLIP is only necessary because this system uses HP printers. It is not
      # needed for non-HP printers unless their model specifically requires it.
      hplip
    ];
  };

  # GTK administration client for adding and managing CUPS printers.
  environment.systemPackages = [
    pkgs.system-config-printer
  ];
}
