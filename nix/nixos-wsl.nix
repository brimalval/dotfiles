# NixOS-WSL system layer (replaces /etc/nixos/configuration.nix). The user layer is home-nixos-wsl.nix.
# Switch with:
#   sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix
# (nixos-rebuild picks nixosConfigurations.<hostname>, here "nixos")
{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  # Carried over from the stock /etc/nixos/configuration.nix
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos";

  # zsh as the login shell. It has to be enabled here, system-wide, so NixOS lists it in
  # /etc/shells and sets up /etc/zshenv; home-manager doesn't manage zsh (the repo's .zshrc does).
  programs.zsh.enable = true;
  users.users.nixos.shell = pkgs.zsh;

  # git system-wide: flakes need it, and so does root (sudo nixos-rebuild) reading this repo.
  environment.systemPackages = [ pkgs.git ];

  # Run prebuilt Linux binaries that expect /lib64/ld-linux-x86-64.so.2 (Mason's language servers,
  # npm packages with native parts). Without it NixOS refuses them with
  # "Could not start dynamically linked executable".
  programs.nix-ld.enable = true;

  # Set at first install (26.05); don't bump. It isn't the NixOS version you run.
  system.stateVersion = "26.05";
}
