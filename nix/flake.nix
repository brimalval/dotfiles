{
  description = "Brian's dotfiles: nix-darwin + home-manager, and pinned CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        agent-browser = pkgs.callPackage ./pkgs/agent-browser.nix { };
        # Alternative: nixpkgs' own build (from source, cached), when its version matches Herdr's pin:
        agent-browser-nixpkgs = pkgs.agent-browser;
        default = self.packages.${system}.agent-browser;
      };

      # Per-project devShells: `nix flake init -t ~/Projects/dotfiles/nix#node` (or #rust), then `direnv allow`.
      templates = {
        node = { path = ./templates/node; description = "Node + pnpm devShell, loaded by direnv"; };
        rust = { path = ./templates/rust; description = "Rust devShell from rust-toolchain.toml (rust-overlay)"; };
      };

      # sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix
      # (darwin-rebuild picks this by hostname: `scutil --get LocalHostName`)
      darwinConfigurations."Brians-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; myPkgs = self.packages.${system}; };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true; # packages land in /etc/profiles/per-user/brian
            home-manager.backupFileExtension = "before-home-manager";
            home-manager.extraSpecialArgs = { myPkgs = self.packages.${system}; };
            home-manager.users.brian = import ./home.nix;
          }
        ];
      };
    };
}
