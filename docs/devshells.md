# Dev Shells

## The problem devshells solve

If you install `gcc` globally on NixOS it lives in your system forever — every new shell, every project, cluttering your PATH even when you don't need it. On most distros you'd just `apt remove` it later and forget, but managing tool sprawl this way gets old fast.

A devshell is a temporary environment: run a command, drop into a shell with exactly the tools you need, do your work, type `exit`, and those tools disappear. The next shell you open is clean again.

This config ships three ready-made devshells as simple commands: `c-dev`, `py-dev`, and `rs-dev`.

---

## Using the built-in shells

After a `nh os switch`, these commands are in your PATH:

| Command  | Environment | What you get |
|----------|-------------|-------------|
| `c-dev`  | C / General | gcc, gnumake, cmake, gdb, clang-tools, valgrind... |
| `py-dev` | Python      | python3, pip, virtualenv, uv, ruff, black, numpy... |
| `rs-dev` | Rust        | rustc, cargo, clippy, rustfmt, rust-analyzer... |

```bash
$ c-dev

# You're now in the C dev shell.
# gcc, cmake, gdb, etc. are all available.
[nix-shell] $ which gcc
/nix/store/...-gcc-14.2.0/bin/gcc

# Done? Just exit.
[nix-shell] $ exit

# Back to your normal shell — gcc is gone again.
```

Your normal Zsh config (aliases, Powerlevel10k, plugins) is **not** loaded inside the subshell. Only the dev tools are present. This keeps the environment clean and predictable — what you see is what's in the devshell, nothing else.

### How it works under the hood

Each devshell module (`c-general-devshell.nix` etc.) does two things:

1. Defines a `pkgs.mkShell` derivation — this is a special Nix build that just creates a shell environment with a list of packages instead of building something
2. Creates a tiny wrapper script via `pkgs.writeShellScriptBin` that calls `nix-shell <derivation> --command zsh`

That wrapper script is added to `home.packages` so `c-dev` is always in your PATH. The derivation is a dependency of the script, which prevents Nix's garbage collector from cleaning it up.

---

## Project-specific shells

For a project that needs its own pinned environment (specific library versions, unusual tools), create a `flake.nix` at the project root:

```nix
# my-project/flake.nix
{
  description = "My C project";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [
        gcc
        cmake
        gdb
        libsodium  # project-specific dependency
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

### Auto-loading with direnv

If you add `direnv` to your config, you can make the shell load automatically whenever you `cd` into a project:

```bash
# my-project/.envrc
use flake
```

Now every time you enter the directory, the devshell activates. Leave the directory and it deactivates.

---

## Editor integration

### VSCode

Open the integrated terminal and type `c-dev` / `py-dev` / `rs-dev` to drop into a devshell — LSP tools from that shell are then available to the running VSCode process.

For automatic loading, set up a project-specific `flake.nix` and install the **Nix Environment Selector** extension:

```json
{
  "nixEnvSelector.suggestion": true,
  "nixEnvSelector.nixFile": "${workspaceFolder}/flake.nix"
}
```

### Neovim

Run Neovim from inside the devshell and LSP tools will be on PATH:

```bash
c-dev
nvim my-file.c
# clangd is available from the devshell
```

For persistent projects, use a project `flake.nix` + direnv so Neovim always starts with the right environment.

---

## Adding tools to an existing shell

Edit the relevant file in `home-manager/utilities/devshells/`, add the package to the `packages` list inside `pkgs.mkShell`, then rebuild:

```bash
nh os switch
```

---

## Updating

Devshell packages are pinned to the `nixpkgs` version in `flake.lock`. They won't change until you explicitly update:

```bash
# Update all flake inputs (nixpkgs and everything else)
nix flake update ~/GitRepos/nixos-dotfiles

# Rebuild to apply
nh os switch
```

Or just use the `update` shell alias — it does the full chain.

---

## Troubleshooting

**`c-dev: command not found`**
Run `nh os switch` — the wrapper scripts are installed by home-manager and won't exist until after the first rebuild.

**Dev shell feels slow to start**
The first invocation builds the `mkShell` derivation. After that it's cached in the Nix store and starts near-instantly.

**`zsh: command not found: <tool>`**
You're outside the devshell. Run `c-dev` / `py-dev` / `rs-dev` first.

**Missing a library or tool**
Add it to the `packages` list in the relevant `devshells/*.nix` file, then `nh os switch`.
