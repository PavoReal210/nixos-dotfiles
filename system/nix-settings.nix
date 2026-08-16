# system/nix-settings.nix
# Basic nix settings + nixpkgs package policy
{...}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Ryzen 5800X has 8 cores / 16 threads.
      # max-jobs=auto lets the daemon run up to 16 builds in parallel.
      # cores=0 lets each build use all available cores.
      max-jobs = "auto";
      cores = 0;
      # Cachix binary cache for Doom Emacs
      substituters = [
        "https://doom-emacs-unstraightened.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "doom-emacs-unstraightened.cachix.org-1:O5oOlRPnmQEvVaFyuMTmthCEooHbrg54WgSLR07tmg4="
      ];
    };
    gc = {
      # Garabage collector to automatically delete old builds
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  # ── Package policy ────────────────────────────────────────────────────────────

  nixpkgs.config = {
    # Allow unfree packages
    allowUnfree = true;

    # Keep insecure package exceptions empty. Add a narrowly documented,
    # temporary exception only when a package actually requires one.
    permittedInsecurePackages = [];
  };
}
