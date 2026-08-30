# home-manager/utilities/development-tools.nix
# Development tools and configurations
{pkgs, ...}: {
  # Development packages
  home.packages = with pkgs; [
    # Rust
    cargo
    rustc

    # Python
    python3
    python312Packages.pip
    python312Packages.virtualenv
    uv # Fast Python package manager
    ruff # Python linter

    # JavaScript/Node
    nodejs

    # C/C++
    gcc
    gnumake
    cmake
    gdb
    lldb
    clang-tools

    # Nix tools
    nixfmt
    nil # Nix LSP

    # General development
    tmux # Terminal multiplexer
    direnv # Per-directory environment
    opencode # Code editor for vibing-out
    claude-code # Anthropic's Claude Code CLI

  ];

  # Direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
