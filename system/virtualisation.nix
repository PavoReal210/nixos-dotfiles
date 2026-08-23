# system/virtualisation.nix
# libvirtd/KVM for a Windows 11 VM (WinApps backend)
{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true; # TPM 2.0 emulation — required by Windows 11
    };
  };

  # virt-manager for building/managing the VM; freerdp is winapps' RDP backend
  environment.systemPackages = with pkgs; [
    virt-manager
    freerdp
    spice-gtk
  ];

  # winapps reads LIBVIRT_DEFAULT_URI from /etc/environment more reliably
  # than from shell rc files
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  # required for virt-manager's USB redirection and clipboard passthrough
  services.spice-vdagentd.enable = true;
}
