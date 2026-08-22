# system/winapps.nix
{ inputs, system, ... }:
{
  environment.systemPackages = [
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
  ];
}
