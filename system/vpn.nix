# system/vpn.nix
# PIA VPN (WireGuard) + SOPS credentials
#
# Note:
# - age keyfile + world-readable tmpfiles rule live in system/secrets.nix
# - doas rule for pia lives in system/doas.nix
# - systemd-resolved lives in system/network.nix (needed for PIA's dns.enable)
{config, ...}: {
  sops = {
    secrets.pia = {
      # The secret will be available at /run/secrets/pia
      sopsFile = ./secrets/pia.age;
      format = "binary";
      owner = "railgun"; # If you don't establish an owner, when you try to use pia connect it won't work
      mode = "0400";
    };
  };

  services.pia = {
    enable = true;

    # Use the sops secret file
    credentials.credentialsFile = config.sops.secrets.pia.path;

    protocol = "wireguard";

    autoConnect = {
      enable = false;
    };

    # Optional settings
    portForwarding.enable = true;
    dns.enable = true;
  };
}
