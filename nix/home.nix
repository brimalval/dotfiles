# User layer (home-manager, run inside nix-darwin). Phase 1: wired up, deliberately empty.
# Packages listed here land in /etc/profiles/per-user/brian/bin, ahead of Homebrew on PATH.
# Dotfiles are still placed by stow until phase 4.
{ pkgs, myPkgs, ... }:

{
  home.username = "brian";
  home.homeDirectory = "/Users/brian";
  home.stateVersion = "26.11"; # set once at first install; don't bump

  home.packages = [
    # Phase 2 moves CLI tools here from homebrew.brews in darwin.nix, e.g.:
    # pkgs.ripgrep
    # agent-browser stays in `nix profile` for now (HERDR_BROWSER_BIN in .zshenv points there):
    # myPkgs.agent-browser
  ];

  programs.home-manager.enable = true;
}
