{
  inputs = {
    # CORE =====================================================================
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECRETS ==================================================================
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # THEMING ===============================================================
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cozette.url = "github:railgun210/cozette";
    hm-ricing-mode.url = "github:Markus328/hm-ricing-mode/fix-hm-module";
    buuf-icon-theme.url = "github:railgun210/buuf-gnome";

    # EDITOR ===================================================================
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doomdir = {
      url = "github:railgun210/doom-emacs";
      flake = false;
    };

    # UTILITIES ================================================================
    chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";
    pia = {
      url = "github:railgun210/pia.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    lanzaboote,
    sops-nix,
    stylix,
    cozette,
    buuf-icon-theme,
    hm-ricing-mode,
    nix-doom-emacs-unstraightened,
    chaotic,
    pia,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # These overlays are shared by NixOS and the integrated Home Manager
    # configuration because both now evaluate against the same pkgs set.
    sharedOverlays = [
      overlay-unstable
      nix-doom-emacs-unstraightened.overlays.default
      (final: prev: {cozette = inputs.cozette.packages.${system}.default;})
      (final: prev: {
        buuf-icon-theme = inputs.buuf-icon-theme.packages.${system}.default;
      })
      (final: prev: {pia = inputs.pia.packages.${system}.pia;})
    ];
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    nixosConfigurations = {
      railgun = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          (
            {...}: {
              # NixOS and Home Manager intentionally share this package set.
              nixpkgs.overlays = sharedOverlays;

              # Home Manager is part of the NixOS activation now. A normal
              # `nixos-rebuild switch` rebuilds and activates both layers.
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {inherit inputs;};
                users.railgun = {
                  imports = [
                    nix-doom-emacs-unstraightened.homeModule
                    hm-ricing-mode.homeManagerModules.hm-ricing-mode
                    sops-nix.homeManagerModules.sops
                    ./home-manager/home.nix
                  ];
                };
              };
            }
          )
          ./system/configuration.nix
          home-manager.nixosModules.home-manager
          pia.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          chaotic.nixosModules.nyx-cache
          chaotic.nixosModules.nyx-overlay
          chaotic.nixosModules.nyx-registry
        ];
      };
    };
  };
}
