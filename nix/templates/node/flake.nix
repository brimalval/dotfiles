{
  description = "Node devShell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        # Pick the project's versions here: nodejs_22, nodejs_24, nodejs_26; pnpm_10, pnpm_11, ...
        packages = [ pkgs.nodejs_24 pkgs.pnpm_11 ];
      };
    };
}
