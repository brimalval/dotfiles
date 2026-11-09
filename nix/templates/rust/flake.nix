{
  description = "Rust devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, rust-overlay, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; overlays = [ rust-overlay.overlays.default ]; };
      # Uses ./rust-toolchain.toml when the project has one; otherwise latest stable.
      toolchain =
        if builtins.pathExists ./rust-toolchain.toml
        then pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
        else pkgs.rust-bin.stable.latest.default.override { extensions = [ "rust-src" "rust-analyzer" ]; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ toolchain ];
      };
    };
}
