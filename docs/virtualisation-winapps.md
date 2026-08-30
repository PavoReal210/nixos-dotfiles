# Virtualization and WinApps

## What this does

WinApps lets individual Windows apps — Word, Outlook, Photoshop, whatever — appear as normal windows on your Linux desktop. They show up in your app launcher, open from keybindings, and sit in your taskbar just like any native app. Under the hood they're running in a headless Windows 11 VM over RDP.

### Why this setup instead of alternatives?

**Why not just open the VM in a window?** You could, but then you're staring at a Windows desktop inside a window. WinApps makes each app feel native — no Windows taskbar, no VM window border, just the app.

**Why not GPU passthrough?** GPU passthrough gives the VM direct GPU access for gaming or GPU-accelerated work, but it requires *two* GPUs — one for the host, one for the VM. This machine only has the RTX 4060, which the Linux host needs. WinApps doesn't need GPU passthrough; it uses Windows RDP for display, which is fast enough for office apps.

**Why not WINE?** WINE works great for many apps but breaks on anything that checks for Windows authenticity, requires specific Windows APIs, or just hasn't been tested. A real Windows VM works with anything.

> **Important:** This only works with **Windows Pro, Enterprise, or Education**. Windows Home does not support incoming RDP connections, so WinApps won't work with it. You need a Pro license (or higher).

---

## What the Nix config sets up

| File | What it does |
|------|-------------|
| `system/virtualisation.nix` | Enables libvirt/KVM, QEMU-KVM, TPM 2.0, Virt-Manager, SPICE, FreeRDP |
| `system/winapps.nix` | Installs WinApps and its launcher |
| `system/users.nix` | Adds your user to the `libvirtd` and `kvm` groups |
| `flake.nix` | Pins the WinApps flake input to a known-good version |

The Nix config does NOT create the Windows VM, download Windows, or store any Windows credentials. You do that part yourself.

Apply the config first:

```bash
nh os switch
```

Then log out and back in so the group membership takes effect. Verify everything looks right:

```bash
groups                              # should include libvirtd and kvm
ls -l /dev/kvm                      # should exist
virt-host-validate qemu             # should all pass
virsh -c qemu:///system list --all  # should connect without errors
xfreerdp3 --version                 # should print a version number
```

---

## Step 1 — Get a Windows 11 ISO

Download from Microsoft's official page:

<https://www.microsoft.com/software-download/windows11>

Make sure you download a Pro, Enterprise, or Education edition — not Home.

Move it somewhere Virt-Manager can access:

```bash
mkdir -p ~/VirtualMachines/iso
mv ~/Downloads/Win11*.iso ~/VirtualMachines/iso/windows-11.iso
```

If Virt-Manager can't access files from your home directory, put it in `/var/lib/libvirt/images/` instead.

---

## Step 2 — Create the Windows VM

Open Virt-Manager and connect to **QEMU/KVM system** (not the session connection — WinApps uses `qemu:///system`).

Click **Create a new virtual machine** and go through the wizard:

1. Select **Local install media (ISO image or CDROM)** → pick the Windows 11 ISO
2. Choose **Microsoft Windows 11** as the OS type
3. Allocate **12–16 GiB of RAM** (the host has 32 GiB)
4. Allocate **6 vCPUs** to start (go to 8 only if you notice it being a bottleneck)
5. Create a **qcow2 disk of at least 80 GiB** on local SSD storage
6. Check **Customize configuration before install**

Before starting, verify these settings in the customization screen:

| Setting | Value |
|---------|-------|
| Firmware | UEFI/OVMF |
| Machine type | Q35 |
| CPU model | host-passthrough |
| TPM | TPM 2.0 (emulator backend) |
| Disk bus | VirtIO |
| Network | VirtIO, attached to default NAT network |
| Display | SPICE |
| Boot order | ISO first, then the disk |

---

## Step 3 — Install Windows

Boot the VM and install Windows normally. If the installer can't find the VirtIO disk, you need to load the VirtIO storage driver:

1. Download the VirtIO driver ISO: <https://github.com/virtio-win/virtio-win-pkg-scripts/releases>
2. Attach it to the VM as a second CD drive
3. In the installer's "Where to install Windows" screen, click **Load driver** and browse to the VirtIO storage driver

Alternatively, temporarily switch the disk to SATA for installation, then switch it back to VirtIO afterward.

After Windows reaches the desktop:
1. Install VirtIO storage and network drivers from the VirtIO ISO
2. Install the QEMU guest agent (optional but useful)
3. Run Windows Update fully
4. Shut down, switch any remaining SATA devices to VirtIO, reboot and confirm networking works

---

## Step 4 — Sign in and set a password

During setup or later under **Settings > Accounts**, sign in with a Microsoft account.

> **Critical:** WinApps connects via RDP, and RDP requires an actual account password. A Windows Hello PIN is **not** an RDP password.

Before continuing:
1. Confirm you can sign in with your Microsoft account *password* (not just PIN)
2. If Windows only shows PIN options, go to **Settings > Accounts > Sign-in options** and set a password
3. Note the Windows account username and email — you'll need both later

Check Windows activation under **Settings > System > Activation**. If it doesn't activate automatically, use the activation troubleshooter and select "I changed hardware on this device" if applicable.

---

## Step 5 — Enable Remote Desktop in Windows

Go to **Settings > System > Remote Desktop** and turn it on. Leave **Network Level Authentication** enabled.

The libvirt NAT network assigns the VM an address in `192.168.122.0/24`. Find it:

```bash
virsh -c qemu:///system list --all
virsh -c qemu:///system domifaddr RDPWindows  # replace with your VM name
```

Test the RDP connection before going further:

```bash
xfreerdp3 /u:'WINDOWS_USER' /p:'WINDOWS_PASSWORD' \
  /v:192.168.122.123:3389 /cert:tofu
```

If this connects, you're ready for WinApps.

---

## Step 6 — Configure WinApps

Create the config file:

```bash
mkdir -p ~/.config/winapps
${EDITOR:-vi} ~/.config/winapps/winapps.conf
chmod 600 ~/.config/winapps/winapps.conf
```

Minimum config:

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

Key settings:
- `WAFLAVOR="libvirt"` — tells WinApps to manage the VM through libvirt
- `VM_NAME` — must exactly match the libvirt domain name (check with `virsh list --all`)
- `RDP_IP=""` — empty lets WinApps discover the IP through libvirt automatically
- `RDP_SCALE="140"` — good for 1440p/4K; use `180` if text is too small
- Never commit this file — it has your Windows password in it

Run the setup wizard (Windows must be powered on):

```bash
winapps-setup --user
```

This scans Windows for installed apps and creates `.desktop` files for each one, so they appear in your app launcher.

To pick up apps installed later:

```bash
winapps-setup --user --add-apps
```

To launch the WinApps launcher directly:

```bash
winapps-launcher
```

---

## Troubleshooting

**No VM found**

```bash
virsh -c qemu:///system list --all
echo $LIBVIRT_DEFAULT_URI  # should be qemu:///system
```

Log out and back in if you just added your user to the `libvirtd` group.

**Default network is inactive**

```bash
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-autostart default
```

**RDP authentication fails**

Check: correct Windows edition (Pro/Enterprise), Remote Desktop enabled, account has a password (not just PIN), username format is right (`MicrosoftAccount\\you@example.com` for Microsoft accounts), Windows firewall isn't blocking port 3389.

Test with FreeRDP directly to isolate whether it's WinApps or RDP:

```bash
xfreerdp3 /u:'WINDOWS_USER' /p:'WINDOWS_PASSWORD' /v:192.168.122.X:3389 /cert:tofu
```

**Apps show in setup but don't launch**

Make sure the VM is running, then re-run `winapps-setup --user`. Check `~/.local/share/winapps/winapps.log` (set `DEBUG="true"` in the config). Clear stale certificates: `rm -rf ~/.config/freerdp/server/192.168.122.*`

**VM is slow**

Verify: KVM acceleration is active (`virt-host-validate qemu`), CPU model is `host-passthrough`, disk is VirtIO on a local SSD, enough RAM allocated. Only add CPU pinning or hugepages after actually measuring a bottleneck.

---

## Updating WinApps

WinApps is pinned by `flake.lock`. To update to a newer version:

```bash
nix flake lock --update-input winapps ~/GitRepos/nixos-dotfiles
nh os switch
winapps-setup --user  # re-run if app definitions changed
```
