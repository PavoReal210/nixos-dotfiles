# home-manager/utilities/vscode.nix
# VSCode configuration with a standalone (non-Stylix) theme
{
  lib,
  pkgs,
  ...
}:
let
  ellsp = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "Ellsp";
    publisher = "jcs090218";
    version = "0.1.3";
    hash = "sha256-u2gvNxDQJLIWIKF+HhyqQJVfTAZFvzHlwno7wqNXwhA=";
  };

  turbo-c-theme = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "turboc-3-0-theme";
    publisher = "WatkinsLabs";
    version = "0.0.1";
    hash = "sha256-cjQxQr1Yt1twcuTFpQ6ZPDrC4mLGLa+inCnH36dPGm8=";
  };
in
{
  # Force VS Code (and all Electron apps) to use the native Wayland backend
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.vscode = {
    enable = true;

    profiles.default = {
      # Extensions
      # Note: Many extensions (especially proprietary ones like GitHub Copilot,
      # MS dotnet tools, and remote extensions) are not packaged in nixpkgs and
      # must be installed manually through the VSCode UI. They will persist fine
      # alongside nix-managed extensions.
      # It's not an exactly perfect system but other than just using Neovim this is the best option.
      extensions =
        with pkgs.vscode-extensions;
        [
           # Theme

          # Nix
          jnoortheen.nix-ide
          mkhl.direnv

          # Python
          ms-python.python
          ms-python.debugpy
          ms-python.isort
          ms-python.vscode-pylance

          # Rust
          rust-lang.rust-analyzer

          # C/C++
          ms-vscode.cpptools

          # Docker
          ms-azuretools.vscode-docker

          # Jupyter
          ms-toolsai.jupyter

          # Java
          redhat.java
          vscjava.vscode-java-debug
          vscjava.vscode-java-dependency
          vscjava.vscode-java-test
          vscjava.vscode-maven
          vscjava.vscode-gradle

          # Git
          donjayamanne.githistory

          # Vim
          vscodevim.vim

          # Misc
          mechatroner.rainbow-csv
          njpwerner.autodocstring
          shd101wyy.markdown-preview-enhanced
        ]
         ++ [ ellsp turbo-c-theme ];

      userSettings = {
         # Theme — Turbo C 3.0, set explicitly instead of Stylix's generated theme
         "workbench.colorTheme" = "Turbo C 3.0 Theme";

        # Window
        "window.newWindowDimensions" = "default";
        "window.restoreWindows" = "none";

        "security.workspace.trust.untrustedFiles" = "open";

        # Editor — font set directly instead of via Stylix's font option
        "editor.fontFamily" = "'Terminess Nerd Font Mono'";
        "editor.fontSize" = 16;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "boundary";
        "editor.tabSize" = 2;

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";

        # Git
        "git.autofetch" = true;
        "git.confirmSync" = false;

        # Vim
        "vim.useSystemClipboard" = true;
        "vim.hlsearch" = true;

        # Wayland rendering fix — custom title bar avoids XWayland issues
        "window.titleBarStyle" = "custom";
      };
    };
  };
}
