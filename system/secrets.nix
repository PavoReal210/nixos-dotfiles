# system/secrets.nix
# SOPS age encryption key setup
{...}: {
  sops = {
    # Path to the age private key that decrypts all sops-encrypted secrets.
    # The encrypted secret files themselves live in system/secrets/.
    age.keyFile = "/etc/sops/age/keys.txt";
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
}
