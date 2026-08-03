# system/ananicy.nix
# ananicy-cpp: automatic process nice-level management
#
# ananicy-cpp runs as a daemon and adjusts process nice levels based on rules.
# CachyOS ruleset classifies common foreground, gaming and background tasks.
# it measurably improves desktop responsiveness under load.
{pkgs, ...}: {
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos_git;
  };
}
