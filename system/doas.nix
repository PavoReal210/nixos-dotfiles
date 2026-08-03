# system/doas.nix
# doas: minimal sudo replacement
#
# pia re-execs connect/disconnect as root via ensure_root()
# It checks for doas first, then sudo. Without a TTY, sudo
# can't prompt for a password, so doas with NOPASSWD handles it.
{...}: {
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      users = ["railgun"];
      cmd = "/run/current-system/sw/bin/pia";
      noPass = true;
    }
  ];
}
