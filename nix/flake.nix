{
  description = "Brian's dotfiles: pinned CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Stage 2 (home-manager): uncomment
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
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

      # Stage 2: standalone home-manager, `home-manager switch --flake ~/Projects/dotfiles/nix#brian`
      # homeConfigurations.brian = inputs.home-manager.lib.homeManagerConfiguration {
      #   inherit pkgs;
      #   extraSpecialArgs = { myPkgs = self.packages.${system}; };
      #   modules = [ ./home.nix ];
      # };
    };
}
