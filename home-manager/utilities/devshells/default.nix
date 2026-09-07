# home-manager/utilities/devshells/default.nix
# Import hub for all devshell modules
# Each module provides a zsh alias to enter a pinned dev environment
{...}: {
  imports = [
    ./c-general-devshell.nix
    ./ml-devshell.nix
    ./python-devshell.nix
    ./rust-devshell.nix
  ];
}
