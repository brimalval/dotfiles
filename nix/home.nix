# User layer (home-manager, run inside nix-darwin).
# Packages land in /etc/profiles/per-user/brian/bin, ahead of Homebrew on PATH.
# Dotfiles are still placed by stow until phase 4.
{ pkgs, myPkgs, ... }:

{
  home.username = "brian";
  home.homeDirectory = "/Users/brian";
  home.stateVersion = "26.11"; # set once at first install; don't bump

  # Phase 2: CLI tools moved off Homebrew (2026-11-09).
  home.packages = with pkgs; [
    # search, files, navigation
    ripgrep
    eza
    fzf
    zoxide
    yazi
    stow # goes away in phase 4

    # editor and terminal
    neovim
    tree-sitter # brew's tree-sitter + tree-sitter-cli; nvim-treesitter uses the CLI
    tmux # tmux-fingers loads from Nix, see xdg.dataFile below
    starship
    lazygit

    # git and GitHub
    gh
    git-filter-repo
    actionlint

    # media (yazi previews, herdr-wallpaper)
    ffmpeg
    imagemagick
    poppler-utils
    chafa
    whisper-cpp

    # cloud and infra
    cloudflared
    flyctl
    terraform # unfree (BSL); allowed in darwin.nix
    kubernetes-helm
    natscli
    nats-server

    # languages and misc
    uv
    jdk17 # brew's openjdk@17 was keg-only and never linked; now `java` is on PATH
    libfaketime
    blueutil
  ];
  # Stays on Homebrew (darwin.nix): railway (nixpkgs is ~30 releases behind), docker, postgresql@18, fnm.
  # agent-browser stays in `nix profile` until HERDR_BROWSER_BIN moves; see README.

  # tmux-fingers: nixpkgs bakes its binary path into the plugin script rather than putting
  # `tmux-fingers` on PATH, so tmux loads the plugin from here instead of from TPM.
  # Lives under ~/.local/share, not ~/.config/tmux (that one is stowed into the repo).
  xdg.dataFile."tmux/nix-plugins.conf".text = ''
    run-shell ${pkgs.tmuxPlugins.fingers.rtp}
  '';

  programs.home-manager.enable = true;
}
