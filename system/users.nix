# system/users.nix
# General users settings.
{pkgs, ...}: {
  # Define a user group that's the same as the username
  users.groups.railgun = {};
  programs.zsh.enable = true;
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.railgun = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "railgun"
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.zsh;
  };
}
