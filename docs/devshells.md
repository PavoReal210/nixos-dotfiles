# DevShells

This config provides pinned development environments that you can drop into
from your terminal. Each devShell gives you temporary access to a curated set
of tools without permanently installing them into your base system.

The devShells are defined as `mkShell` derivations in home-manager modules
under `home-manager/devshells/`. Their packages are pulled from the flake's
pinned `nixpkgs`, so they stay version-locked until you `nix flake update`.

For Neovim editor integration, see [neovim-dotfiles/README.md](../neovim-dotfiles/README.md#system-dependencies).

---

## 1. Usage

After running a NixOS switch, these commands are available in your PATH:

| Command   | DevShell   | Tools                                              |
| --------- | ---------- | -------------------------------------------------- |
| `c-dev`   | C/General  | gcc, gnumake, cmake, gdb, clang-tools, valgrind... |
| `py-dev`  | Python     | python3, pip, virtualenv, uv, ruff, black, numpy.. |
| `rs-dev`  | Rust       | rustc, cargo, clippy, rustfmt, rust-analyzer...    |

```bash
# Example
$ c-dev

# You are now inside the C dev shell.
# gcc, cmake, gdb, etc. are all available.
[nix-shell] $ which gcc
/nix/store/...-gcc-14.2.0/bin/gcc

# When done, exit back to your normal shell
[nix-shell] $ exit
```

The dev shell uses `zsh` (matching your default shell). Your normal zsh config
(aliases, plugins, theme) is **not** loaded inside the subshell -- only the dev
tools are present. This keeps the environment clean and predictable.

### How it works

Each devShell module (`c-general-devshell.nix`, etc.) does two things:

1. Defines a `pkgs.mkShell` derivation with the tool list
2. Creates a small wrapper script via `pkgs.writeShellScriptBin` that runs
   `nix-shell <derivation> --command zsh`

The script is added to `home.packages`, so `c-dev` is available anywhere in
your PATH. The derivation is a build dependency of the script, which protects
it from garbage collection.

---

## 2. Creating project-specific devShells

For a project that needs its own pinned environment (e.g., a C project needing
a specific library), create a `flake.nix` at the project root:

```nix
# my-project/flake.nix
{
  description = "My C project";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${stdenv.hostPlatform.system};
  in {
    devShells.${stdenv.hostPlatform.system}.default = pkgs.mkShell {
      packages = with pkgs; [
        gcc
        cmake
        gdb
        # Project-specific dependencies
        libsodium
        openssl
      ];

      shellHook = ''
        echo "Welcome to my-project dev shell!"
        export BUILD_DIR="$PWD/build"
      '';
    };
  };
}
```

Then enter it:

```bash
cd my-project
nix develop
```

### Using direnv for auto-loading

If you have `direnv` enabled, create a `.envrc` file in the project root:

```bash
# my-project/.envrc
use flake
```

Now every time you `cd` into the project, the devShell loads automatically.

---

## 3. Troubleshooting

### "c-dev: command not found"

The dev shell scripts are installed by home-manager. Make sure you've run:

```bash
sudo nixos-rebuild switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

### "cannot find path to derivation"

The derivation reference in the wrapper script points to a store path. If it
was garbage-collected, just re-run the NixOS switch to rebuild it.

### Dev shell feels slow to start

The first invocation builds the `mkShell` derivation. Subsequent invocations
are near-instant because the result is cached in the Nix store.

### "zsh: command not found: <tool>"

You're outside the dev shell. Run `c-dev` / `py-dev` / `rs-dev` first.

### Missing a library or tool

Edit the relevant file in `home-manager/devshells/`, add the package to the
`packages` list inside `pkgs.mkShell`, then run:

```bash
sudo nixos-rebuild switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

---

## 4. Updating devShells

The devShell packages come from `nixpkgs`, which is pinned by the flake's
`flake.lock`. They won't change unless you explicitly update:

```bash
# Update ALL inputs (nixpkgs and everything else)
nix flake update ~/GitRepos/nixos-dotfiles

# After updating, rebuild the system to apply new package versions
sudo nixos-rebuild switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

Or use your existing `update` alias which does the full rebuild chain:

```bash
update
```

To add a new tool to an existing devShell:

1. Edit the module in `home-manager/devshells/` (e.g. `c-general-devshell.nix`)
2. Add the package to the `packages` list inside `pkgs.mkShell`
3. Run `sudo nixos-rebuild switch --flake ~/GitRepos/nixos-dotfiles#railgun` to install the updated script

---

## 5. Editor integration

### VSCode

Since the devShells are now home-manager scripts rather than flake devShells,
the easiest way to use them with VSCode is to open the integrated terminal
and type `c-dev` / `py-dev` / `rs-dev` manually.

If you want the terminal inside VSCode to automatically load a devShell,
set up a project-specific `flake.nix` (see section 2) with a
`.vscode/settings.json` using the **Nix Environment Selector** extension:

```json
{
  "nixEnvSelector.suggestion": true,
  "nixEnvSelector.nixFile": "${workspaceFolder}/flake.nix"
}
```

### Neovim (via nvf)

Run nvim from inside a devShell to get LSP access:

```bash
c-dev
nvim my-file.c
# clangd, gdb, etc. are all available from the devShell
```

Alternatively, for persistent projects, create a `flake.nix` in the project
root (see section 2) and enter it with `nix develop` before launching nvim.

The `c-dev` / `py-dev` / `rs-dev` commands remain useful for one-off terminal
sessions; for editor integration, use `shell.nix` + direnv instead.
