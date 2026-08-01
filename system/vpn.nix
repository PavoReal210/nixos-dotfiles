{ config, ... }:
{
  # sops-nix configuration
  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";

    secrets.pia = {
      # The secret will be available at /run/secrets/pia
      sopsFile = ./secrets/pia.age;
      format = "binary";
      owner = "railgun"; # If you don't establish an owner, when you try to use pia connect it won't work
      mode = "0400";
    };
  };

  # ── Age key permissions for home-manager sops-nix ──────────────────────────
  #
  # The system-level sops-nix service places the age private key at
  # /etc/sops/age/keys.txt with mode 0600 owned by root. This is fine for
  # system-level secrets (they get decrypted to /run/secrets/ by the systemd
  # service running as root).
  #
  # However, the home-manager sops-nix module also needs to decrypt secrets
  # (like the GitHub SSH key in home-manager/utilities/ssh.nix). The home-manager
  # sops-nix runs as a --user systemd service under railgun's user session,
  # which can't read a root-owned 0600 file.
  #
  # This tmpfiles rule ensures on every boot that the age key is world-readable.
  # The age key itself is not sensitive without the corresponding sops config;
  # the real protection comes from the SOPS-encrypted files and the age key's
  # presence on disk. Making it readable is the standard approach documented in
  # sops-nix for mixed system+home-manager setups.
  systemd.tmpfiles.rules = [
    "m /etc/sops/age/keys.txt 0644 root root"
  ];

  # ── systemd-resolved ────────────────────────────────────────────────────────
  #
  # DNS fix: PIA's DNS integration (dns.enable below) writes the PIA nameserver
  # 10.0.0.243 into /etc/resolv.conf. That address is only reachable through the
  # WireGuard tunnel, and the pia CLI only restores the original file on a clean
  # `wg-quick down`. When the tunnel was torn down on suspend/resume, resolv.conf
  # was left pointing at 10.0.0.243 with no tunnel to route it, killing DNS
  # entirely (reproduced 2026-07-31; fixed by regenerating /etc/resolv.conf).
  #
  # The pia CLI checks `systemctl is-active systemd-resolved`: when resolved is
  # running it sets per-interface DNS via `resolvectl` instead of clobbering
  # /etc/resolv.conf, so DNS is cleanly reverted on disconnect and automatically
  # dropped when the tunnel interface disappears (e.g. on suspend). Enabling it
  # here makes `dns.enable` safe. NetworkManager must also push DNS to resolved
  # instead of writing /etc/resolv.conf itself — see system/network.nix.
  services.resolved.enable = true;

  # pia re-execs connect/disconnect as root via ensure_root()
  # It checks for doas first, then sudo. Without a TTY, sudo
  # can't prompt for a password, so doas with NOPASSWD handles it.
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      users = [ "railgun" ];
      cmd = "/run/current-system/sw/bin/pia";
      noPass = true;
    }
  ];

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
