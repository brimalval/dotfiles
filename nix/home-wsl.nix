# WSL-only user layer (standalone home-manager on Debian; no nix-darwin). Shared packages and settings: home.nix.
# Packages land in ~/.nix-profile/bin. Switch with:
#   home-manager switch -b before-home-manager --flake ~/Projects/dotfiles/nix
{ ... }:

{
  imports = [ ./home.nix ];

  home.username = "vaiciel";
  home.homeDirectory = "/home/vaiciel";

  # Non-NixOS Linux: XDG_DATA_DIRS, terminfo and locale paths for Nix-installed programs.
  targets.genericLinux.enable = true;

  # Docker comes from Docker Desktop on the Windows side (.zshrc.wsl puts its CLI on PATH).
}
