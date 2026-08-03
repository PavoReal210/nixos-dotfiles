# system/desktop-manager.nix
# greetd + ReGreet display manager, themed by Stylix (see system/stylix.nix).
# nixpkgs wires up greetd + the cage Wayland compositor automatically.

{ ... }:
{
  services.displayManager.regreet.enable = true;
}
