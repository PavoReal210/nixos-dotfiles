# home-manager/utilities/anki.nix
# Anki — declaratively managed via the home-manager `programs.anki` module:
# package (pkgs.anki), addons, and AnkiWeb sync credentials from sops.
# The module's built-in `hm-sync-config` addon applies the username + sync key
# at profile open, so you never log in manually.
{ config, pkgs, ... }:

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
in
{
  programs.anki = {
    enable = true;
    package = pkgs.anki;
    addons = [ multi-line-type-answer-box ];
    profiles."User 1".sync = {
      usernameFile = config.sops.secrets.anki-username.path;
      keyFile = config.sops.secrets.anki-sync-key.path;
    };
  };

  # AnkiWeb sync credentials. Decrypted to ~/.config/sops-nix/secrets/ by the
  # sops-nix user service; read by the hm-sync-config addon at runtime, so they
  # never end up in the nix store.
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.anki-username.sopsFile = ../../system/secrets/secrets.yaml;
    secrets.anki-sync-key.sopsFile = ../../system/secrets/secrets.yaml;
  };
}
