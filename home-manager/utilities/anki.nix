# home-manager/utilities/anki.nix
# Anki — declaratively managed via the home-manager `programs.anki` module:
# package (pkgs.anki), addons, and AnkiWeb sync credentials from sops.
# The module's built-in `hm-sync-config` addon applies the username + sync key
# at profile open, so you never log in manually.
{
  config,
  pkgs,
  ...
}:
let
  # "Multi-Line Type Answer Box - 2" (ankiweb id 1018107736), pinned from the
  # ankiweb download endpoint. tinycss/speedups.so is a macOS Mach-O binary
  # that can't load on Linux — tinycss falls back to pure Python — so we drop
  # it (and the __MACOSX junk) from the package.
  multi-line-type-answer-box = pkgs.anki-utils.buildAnkiAddon {
    pname = "multi-line-type-answer-box";
    version = "2.0";
    src = pkgs.fetchurl {
      url = "https://ankiweb.net/shared/download/1018107736?v=2.1&p=1018107736";
      hash = "sha256-RKxt0n+0mo+xzgUEcOuiW8gfQD4QgzbyTpV2mmnsuXs=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = ''
      unzip $src -d .
      rm -rf __MACOSX
      rm -f tinycss/speedups.so
    '';
  };

  # The current nixpkgs Anki package exports workspace development dependencies
  # even for its root project. That project has no runtime dependencies, so
  # skip its export and keep only the qt/pylib production dependency exports.
  anki = pkgs.anki.overrideAttrs (old: {
    buildPhase =
      builtins.replaceStrings
        [
          "uv export --no-dev | strip_versions > requirements.txt"
          "uv export --project qt --extra qt --extra audio"
          "uv export --project pylib |"
        ]
        [
          "printf '' > requirements.txt"
          "uv export --project qt --extra qt --extra audio --no-dev --no-group dev"
          "uv export --project pylib --no-dev --no-group dev |"
        ]
        old.buildPhase;

    # pkgs.anki's original passthru captures the unpatched package. Replace
    # its input in the addon wrapper so Home Manager uses this fixed package.
    passthru = (old.passthru or { }) // {
      withAddons =
        addons:
        (old.passthru.withAddons addons).overrideAttrs (_: {
          paths = [ anki ];
        });
    };
  });
in
{
  programs.anki = {
    enable = true;
    package = anki;
    addons = [
      multi-line-type-answer-box
    ];
    profiles."User 1".sync = {
      usernameFile = config.sops.secrets.anki-username.path;
      keyFile = config.sops.secrets.anki-sync-key.path;
    };
  };

  # AnkiWeb sync credentials. Decrypted to ~/.config/sops-nix/secrets/ by the
  # sops-nix user service; read by the hm-sync-config addon at runtime, so they
  # never end up in the nix store.
  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";
    secrets.anki-username.sopsFile = ../../system/secrets/secrets.yaml;
    secrets.anki-sync-key.sopsFile = ../../system/secrets/secrets.yaml;
  };
}
