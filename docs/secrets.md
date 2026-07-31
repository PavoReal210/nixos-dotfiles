# Secrets Management (SOPS)

SOPS (Secrets OPerationS) is used for managing encrypted secrets in this configuration. Secrets are stored as age-encrypted YAML files in `system/secrets/`.

## Prerequisites

1. Install SOPS:
   ```bash
   nix shell nixpkgs#sops
   ```

2. Generate an age key (if you don't have one):
   ```bash
   mkdir -p ~/.config/sops/age/
   nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
   ```

## Adding WiFi to SOPS (after initial setup)

1. Enter the dotfiles directory:
   ```bash
   cd ~/GitRepos/nixos-dotfiles
   ```

2. Edit the secrets:
   ```bash
   sops system/secrets/secrets.yaml
   ```

3. Add your WiFi credentials:
   ```yaml
   wifi:
       ssid: "YourNetworkName"
       psk: "YourPassword"
   ssh_key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     your-private-key-here
     -----END OPENSSH PRIVATE KEY-----
   ```

4. Encrypt your SSH keys:
   ```bash
   sops --encrypt --age <your-public-age-key> ~/.ssh/github.pub > system/secrets/github-ssh-key.pub
   ```

5. Save and exit. The file will be encrypted automatically.

## After updating secrets

Rebuild your system. See [README Rebuilding](../README.md#rebuilding) for instructions.

## Useful Tips

### Setting an Editor

Use vim as the SOPS editor:
```bash
EDITOR=vim sops system/secrets/secrets.yaml
```

## Adding RetroAchievements credentials

RetroArch's RetroAchievements login is stored in `retroachievements-username` / `retroachievements-password`:

1. Edit the secrets:
   ```bash
   sops system/secrets/secrets.yaml
   ```
2. Add the two keys:
   ```yaml
   retroachievements-username: "your_username"
   retroachievements-password: "your_password"
   ```
3. Rebuild home (`nh home switch`). The values are seeded into `~/.config/retroarch/retroarch.cfg` at activation, never into the nix store.

## Encrypted Files

| File | Purpose |
|------|---------|
| `secrets.yaml` | Main secrets (WiFi, PIA VPN, RetroAchievements) |
| `github-ssh-key.age` | GitHub SSH private key |
| `github-ssh-key.pub` | GitHub SSH public key (encrypted with age) |
| `pia.age` | PIA VPN configuration |
| `weather-api-key.age` | Weather API key for waybar module |
