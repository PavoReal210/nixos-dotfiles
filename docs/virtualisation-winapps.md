# Virtualization and WinApps

This guide explains how this NixOS configuration provides a Windows 11 VM
through libvirt/KVM and how to expose Windows applications through WinApps.
The host configuration is declarative, but the Windows guest, its disk image,
RDP credentials, and Microsoft account remain outside the Nix store.

## 1. What the configuration provides

| File | Purpose |
| --- | --- |
| `system/virtualisation.nix` | Enables libvirt/KVM, QEMU-KVM, TPM 2.0, Virt-Manager, SPICE, and FreeRDP |
| `system/winapps.nix` | Installs WinApps, the optional launcher, and setup utilities |
| `system/users.nix` | Adds the user to the `libvirtd` and `kvm` groups |
| `flake.nix` | Pins the WinApps flake input |

Apply the host configuration first:

```bash
cd ~/GitRepos/nixos-dotfiles
sudo nixos-rebuild switch --flake .#railgun
```

Log out and back in after the first activation if the `libvirtd` or `kvm`
group membership is not visible in the current session. Confirm the host:

```bash
groups
ls -l /dev/kvm
virt-host-validate qemu
virsh -c qemu:///system list --all
xfreerdp3 --version
```

## 2. Host hardware and performance

This machine has an AMD Ryzen 7 5800X with 8 cores and 16 threads. AMD-V/SVM,
nested paging, and IOMMU are available, and the running kernel has KVM's AMD
module loaded.

The configuration uses QEMU-KVM, TPM 2.0 support, AMD P-State active mode, the
performance governor, and full kernel preemption. It keeps normal CPU idle
states and PCIe power management instead of disabling them for small and
usually unmeasurable latency gains.

The RTX 4060 is used by the Linux host. GPU passthrough is technically
possible, but would require another usable host GPU or a graphical hostless
setup. WinApps normally uses Windows RDP and does not require GPU passthrough.
Hugepages and CPU pinning are also intentionally not forced globally; add them
only after measuring a VM-specific bottleneck.

## 3. Obtain Windows installation media

Download a Windows 11 ISO from Microsoft's official page:

<https://www.microsoft.com/software-download/windows11>

Use an ISO matching the edition you are licensed to use. A VM still needs a
valid Windows license. Signing in with a Microsoft account does not itself
create a license or guarantee activation in a new virtual machine.

Keep the ISO somewhere readable by Virt-Manager, for example:

```bash
mkdir -p ~/VirtualMachines/iso
mv ~/Downloads/Win11*.iso ~/VirtualMachines/iso/windows-11.iso
```

If Virt-Manager cannot access the file from your home directory, copy it to
`/var/lib/libvirt/images/` instead.

## 4. Create the Windows VM

Open Virt-Manager and connect to **QEMU/KVM system**. Do not use the `session`
connection; WinApps uses `qemu:///system`.

Choose **Create a new virtual machine**:

1. Select **Local install media (ISO image or CDROM)**.
2. Select the Windows 11 ISO.
3. Choose **Microsoft Windows 11** when available.
4. Allocate 12 to 16 GiB of RAM. The host has 32 GiB.
5. Start with 6 vCPUs. Use 8 only if the workload needs it.
6. Create a qcow2 disk of at least 80 GiB on fast local storage.
7. Enable **Customize configuration before install**.

Verify these settings before starting installation:

- Firmware: **UEFI/OVMF**.
- Machine type: **Q35**.
- CPU model: **host-passthrough**.
- TPM: **TPM 2.0** using the emulator backend.
- Disk: VirtIO when VirtIO drivers are available.
- Network: VirtIO attached to the default NAT network.
- Display: SPICE with a SPICE channel for installation and recovery.
- Boot order: ISO first during installation, then the virtual disk.

NixOS 26.11's QEMU package includes the OVMF images by default, so this
repository does not set the removed `qemuOvmf` options.

For the first installation, SATA storage is acceptable if Windows cannot see a
VirtIO disk. Switch to VirtIO after installing the drivers.

## 5. Install Windows 11

Install Windows normally. If Setup cannot find a VirtIO disk, attach the
VirtIO driver ISO from the Fedora VirtIO project and load the storage driver,
or temporarily use SATA:

<https://github.com/virtio-win/virtio-win-pkg-scripts/releases>

After Windows reaches the desktop:

1. Install the VirtIO storage and network drivers.
2. Install the QEMU guest agent if desired.
3. Install Windows updates.
4. Shut down and change SATA devices to VirtIO if SATA was used initially.
5. Boot again and confirm networking works.

## 6. Sign in with a Microsoft account

During setup or later under **Settings > Accounts**, choose **Sign in with a
Microsoft account** and complete Microsoft's authentication flow. This works
normally in the VM, including Windows Hello.

WinApps uses RDP, and RDP requires an actual Windows account password. A
Windows Hello PIN is not an RDP password. Before configuring WinApps:

1. Confirm the Microsoft account can sign in with its password.
2. If Windows only offers a PIN, open **Settings > Accounts > Sign-in options**
   and add or confirm a password.
3. Note the Windows account name and Microsoft account email address.
4. Keep the password out of this repository and out of Nix expressions.

Windows activation is separate from account sign-in. Check **Settings > System
> Activation**. If a digital license does not activate in the VM, use the
activation troubleshooter and select **I changed hardware on this device**
where applicable, or enter a valid product key. Activation depends on the
license type and Microsoft account entitlement.

Windows Home cannot accept incoming RDP connections as a host. Use Windows Pro,
Enterprise, or Education for the VM, or use another remote-access solution.

## 7. Enable Windows RDP

Open **Settings > System > Remote Desktop**, enable **Remote Desktop**, and
confirm the account is allowed to connect. Keep **Network Level Authentication**
enabled.

The default libvirt NAT network normally assigns the VM an address in the
`192.168.122.0/24` range. WinApps can discover this address with the `libvirt`
backend, so a host-side port forward is not required.

Find the domain name and address:

```bash
virsh -c qemu:///system list --all
virsh -c qemu:///system domifaddr RDPWindows
```

Replace `RDPWindows` with the actual domain name. Test RDP before installing
WinApps integration:

```bash
xfreerdp3 /u:'WINDOWS_USER' /p:'WINDOWS_PASSWORD' \
  /v:192.168.122.123:3389 /cert:tofu
```

Do not leave the password in shell history. If the account is a Microsoft
account, Windows may require the username in the form
`MicrosoftAccount\\you@example.com`; use the format accepted by Windows.

## 8. Configure WinApps

Create the configuration as your normal user:

```bash
mkdir -p ~/.config/winapps
${EDITOR:-vi} ~/.config/winapps/winapps.conf
chmod 600 ~/.config/winapps/winapps.conf
```

Use this minimum configuration, replacing the values:

```ini
RDP_USER="WINDOWS_USER"
RDP_PASS="WINDOWS_PASSWORD"
RDP_DOMAIN=""
RDP_IP=""
RDP_PORT="3389"
VM_NAME="RDPWindows"
WAFLAVOR="libvirt"
RDP_SCALE="140"
RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
DEBUG="true"
AUTOPAUSE="off"
```

For better password hygiene, use `RDP_ASKPASS` instead of `RDP_PASS` and point
it to a user-only command or secret store. Never commit this file.

The important settings are:

- `WAFLAVOR="libvirt"` tells WinApps to manage the libvirt VM.
- `VM_NAME` must exactly match the libvirt domain name.
- An empty `RDP_IP` lets WinApps discover the guest address through libvirt.
- `RDP_SCALE="140"` is a good starting point for a 4K display; use `180` if
  text remains too small.

Run the setup wizard while Windows is powered on:

```bash
winapps-setup --user
```

The wizard queries Windows for installed applications and creates desktop
entries. Detect applications installed later with:

```bash
winapps-setup --user --add-apps
```

The optional launcher is available as:

```bash
winapps-launcher
```

## 9. Troubleshooting

### No VM is found

Confirm the system connection and URI:

```bash
virsh -c qemu:///system list --all
printf '%s\n' "$LIBVIRT_DEFAULT_URI"
```

The URI should be `qemu:///system`. Log in again after adding the user to the
`libvirtd` and `kvm` groups.

### The default network is inactive

Start and persist it through Virt-Manager, or run:

```bash
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-autostart default
```

### RDP authentication fails

Check the Windows edition, Remote Desktop setting, account password, username
format, Windows firewall, and manual FreeRDP connection. A PIN alone is not
enough.

### Applications are detected but do not launch

Ensure the VM is running, then run the setup wizard again. Inspect
`~/.local/share/winapps/winapps.log` when `DEBUG="true"`. Remove stale
certificates only for the affected VM from `~/.config/freerdp/server/`.

### The VM is slow

Verify KVM acceleration, CPU mode `host-passthrough`, VirtIO disk/network
devices, and a local SSD-backed disk. Start with 6 vCPUs and 12 to 16 GiB RAM.
Only add CPU pinning or hugepages after measuring a real bottleneck.

## 10. Updating

WinApps is pinned by `flake.lock`:

```bash
nix flake lock --update-input winapps ~/GitRepos/nixos-dotfiles
sudo nixos-rebuild switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

Rerun `winapps-setup --user` if the WinApps scripts or application definitions
have changed.
