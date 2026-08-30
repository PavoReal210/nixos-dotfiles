# Secrets Management (SOPS)

## The problem

Nix configs live on GitHub. You can't put your WiFi password, SSH keys, or API tokens in a `.nix` file and push it — that's just publishing your credentials to the internet.

SOPS (Secrets OPerationS) solves this: secrets are stored as an encrypted file (`secrets.yaml`) that's safe to commit. Only a machine with the right key can decrypt it. At rebuild time, NixOS decrypts the file and injects the values where they're needed — they never land in the Nix store in plaintext.

This config uses **age** for encryption. Age is simpler than GPG: one key file, no keyring daemon, no web of trust. Your key is at `~/.config/sops/age/keys.txt` for editing, and `/etc/sops/age/keys.txt` for system activation.

---

## What's stored in secrets

| File | What's in it |
|------|-------------|
| `system/secrets/secrets.yaml` | WiFi credentials, PIA VPN config, RetroAchievements login |
| `system/secrets/github-ssh-key.age` | GitHub SSH private key |
| `system/secrets/github-ssh-key.pub` | GitHub SSH public key |
| `system/secrets/pia.age` | PIA VPN WireGuard config |
| `system/secrets/weather-api-key.age` | Weather API key for the Waybar module |

---

## Fresh machine setup

If you're setting up this config on a new machine, you need an age key before secrets will decrypt.

**Step 1 — Generate a new age key**

```bash
mkdir -p ~/.config/sops/age/
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
```

This creates a key file with a private key (keep it secret) and prints your public key to the terminal. Save that public key — you'll need it.

**Step 2 — Copy the key for system services**

SOPS needs the key at `/etc/sops/age/keys.txt` so system-level activation scripts can also decrypt secrets:

```bash
sudo mkdir -p /etc/sops/age
sudo cp ~/.config/sops/age/keys.txt /etc/sops/age/keys.txt
sudo chmod 600 /etc/sops/age/keys.txt
```

**Step 3 — Add your public key to `.sops.yaml`**

Open `.sops.yaml` at the repo root and add your public key to the `age:` list. This tells SOPS which keys can decrypt these secrets. Without this, you'll get "no key found" errors.

**Step 4 — Re-encrypt secrets with your new key**

If you're taking over someone else's config, you need to re-encrypt `secrets.yaml` with your key:

```bash
cd ~/GitRepos/nixos-dotfiles
sops updatekeys system/secrets/secrets.yaml
```

**Step 5 — Rebuild**

```bash
nh os switch
```

---

## Editing secrets

```bash
cd ~/GitRepos/nixos-dotfiles
sops system/secrets/secrets.yaml
```

SOPS decrypts the file into your editor, you make changes, you save — SOPS re-encrypts automatically on write. Set `EDITOR` first if you want a specific editor:

```bash
export EDITOR="emacsclient -a ''"
sops system/secrets/secrets.yaml
```

---

## Adding WiFi credentials

Open `secrets.yaml` and add under `wifi:`:

```yaml
wifi:
  ssid: "YourNetworkName"
  psk: "YourPassword"
```

Then rebuild. NetworkManager picks up the credentials at activation.

---

## Adding RetroAchievements credentials

RetroArch's login is seeded from secrets at activation — credentials never land in the Nix store:

```bash
sops system/secrets/secrets.yaml
```

Add:
```yaml
retroachievements-username: "your_username"
retroachievements-password: "your_password"
```

Rebuild with `nh os switch`. The values are written to `~/.config/retroarch/retroarch.cfg` during activation.

---

## Adding an SSH key

Encrypt your private key with age and store it:

```bash
sops --encrypt --age <your-public-age-key> ~/.ssh/github > system/secrets/github-ssh-key.age
```

The `ssh.nix` module in home-manager then symlinks it into place at activation. The private key itself is never in the Nix store.

---

## After any secrets change

```bash
nh os switch
```

That's it. The rebuild activates the new secrets automatically.
