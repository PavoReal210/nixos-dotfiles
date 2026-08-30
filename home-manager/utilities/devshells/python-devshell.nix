# home-manager/utilities/devshells/python-devshell.nix
# Python development environment
#
# Defines a pinned dev shell derivation and installs a 'py-dev' script to PATH.
# Usage:
#   $ py-dev
#   (enters a subshell with pinned Python tools)
#   $ exit
#   (returns to normal shell)
{pkgs, ...}: let
  pythonDevShell = pkgs.mkShell {
    packages = with pkgs; [
      python3
      python312Packages.pip
      python312Packages.virtualenv
      uv
      ruff
      python312Packages.black
      python312Packages.pytest
      python312Packages.numpy
    ];
  };
in {
  home.packages = [
    (pkgs.writeShellScriptBin "py-dev" ''
      # Enter the pinned Python dev environment
      # Defined in: home-manager/devshells/python-devshell.nix
      exec nix-shell ${pythonDevShell.drvPath} --command zsh
    '')
  ];
}
