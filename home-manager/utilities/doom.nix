# home-manager/utilities/doom.nix
# Doom Emacs via nix-doom-emacs-unstraightened
{
  inputs,
  pkgs,
  ...
}: let
  aspellEnv = pkgs.aspellWithDicts (dicts: with dicts; [en es]);
in {
  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doomdir;
    emacs = pkgs.emacs-pgtk;
    extraBinPackages = with pkgs; [
      ripgrep
      fd
      git
      ispell
      aspellEnv
    ];
  };

  # Run emacs daemon on boot
  services.emacs.enable = true;
}
