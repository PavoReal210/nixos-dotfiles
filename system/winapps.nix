# system/winapps.nix
{
  inputs,
  system,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher

    # Used by winapps-setup and useful when diagnosing RDP/libvirt discovery.
    curl
    dialog
    iproute2
    libnotify
    netcat
  ];
}
