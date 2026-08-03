# home-manager/home.nix
# Main Home Manager configuration.
# This module is imported by the NixOS Home Manager module, so it is rebuilt and
# activated automatically as part of `nixos-rebuild switch`. Its `osConfig`
# argument exposes the surrounding NixOS configuration to Home Manager modules.
{
  config,
  inputs,
  ...
}: {
  imports = [
    # The system Stylix module supplies Stylix's Home Manager module through
    # the integrated NixOS/Home Manager configuration in flake.nix.
    ./theming # This has to get loaded first
    ./utilities
    ./desktops
  ];

  config = {
    # User information
    home = {
      username = "railgun";
      homeDirectory = "/home/railgun";

      # Load wallpapers to the correct folder
      # Is it insane to hard-code wallpapers? Yes of course it is.
      file."Wallpapers" = {
        source = ./wallpapers;
        recursive = true;
      };

      # Session variables
      sessionVariables = {
        EDITOR = "emacsclient -a ''";
        VISUAL = "emacsclient -a ''";
        TERMINAL = "ghostty";
        BROWSER = "floorp";
        # NH flake location
        # NH_FLAKE previously pointed to a local dotfiles folder; use the repo-relative path
        NH_FLAKE = "${config.home.homeDirectory}/GitRepos/nixos-dotfiles";
      };
    };

    # Keep the Home Manager command available inside the managed user profile.
    # The configuration itself is activated by the surrounding NixOS switch.
    programs.home-manager.enable = true;

    # Vanilla neovim (no plugins, for quick terminal edits)
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
    };

    # Start/restart user services when the integrated Home Manager activation runs.
    systemd.user.startServices = "sd-switch";

    # State version - do not change after initial setup
    home.stateVersion = "25.11";
  };
}
