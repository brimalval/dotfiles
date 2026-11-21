# NixOS-WSL user layer (home-manager as a NixOS module, inside nixos-wsl.nix's system). Shared packages: home.nix.
# Packages land in /etc/profiles/per-user/nixos/bin, as on the Mac. Switch with the system:
#   sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix
{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # Build tools that nvim plugins use at install time. The Mac gets these from Xcode's command-line tools.
  home.packages = with pkgs; [
    gcc # nvim-treesitter compiles parsers; telescope-fzf-native, LuaSnip's jsregexp
    gnumake # telescope-fzf-native (`build = "make"`), LuaSnip (`make install_jsregexp`)
    unzip # Mason unpacks most language servers from .zip releases
  ];

  # No targets.genericLinux here: that's for Nix on other distros (home-wsl.nix, Debian). NixOS sets up
  # XDG_DATA_DIRS, terminfo and locales itself.
}
