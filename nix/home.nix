# User layer (home-manager, run inside nix-darwin).
# Packages land in /etc/profiles/per-user/brian/bin, ahead of Homebrew on PATH.
# Dotfile links: links.nix (phase 4; stow is retired).
{ pkgs, myPkgs, ... }:

{
  imports = [ ./links.nix ];

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

    # Phase 3: default toolchains, replacing fnm, rustup, bun's installer and uv's Python downloads.
    # A project that needs other versions gets a devShell (nix/templates), loaded by direnv on cd.
    nodejs_26
    pnpm_11 # pnpm 12 is nixpkgs' default; 11 avoids a lockfile-format bump
    bun
    python3 # 3.14, same minor as the brew python@3.14 that gcloud-cli keeps
    uv # packages and venvs only; Python comes from here or a devShell (UV_PYTHON_DOWNLOADS below)
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    tmux-sessionizer # `tms`, was a `cargo install`

    # languages and misc
    jdk17 # brew's openjdk@17 was keg-only and never linked; now `java` is on PATH
    libfaketime
    blueutil
  ];
  # Stays on Homebrew (darwin.nix): railway (nixpkgs is ~30 releases behind), docker, postgresql@18.
  # agent-browser stays in `nix profile` until HERDR_BROWSER_BIN moves; see README.

  # Exported to every shell by ~/.zshenv, which sources hm-session-vars.sh.
  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never"; # uv uses Nix's Python; no hidden interpreters
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"; # std sources for rust-analyzer
    NPM_CONFIG_PREFIX = "$HOME/.local/share/npm"; # `npm i -g` can't write to the Nix store
  };
  home.sessionPath = [
    "$HOME/.local/share/npm/bin" # npm -g installs
    "$HOME/.cargo/bin" # cargo install
  ];

  # direnv + nix-direnv: `use flake` in a project's .envrc loads its devShell, cached.
  # The zsh hook is in .zshrc (home-manager doesn't manage zsh here).
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # tmux-fingers: nixpkgs bakes its binary path into the plugin script rather than putting
  # `tmux-fingers` on PATH, so tmux loads the plugin from here instead of from TPM.
  # Lives under ~/.local/share, not ~/.config/tmux (that one is stowed into the repo).
  xdg.dataFile."tmux/nix-plugins.conf".text = ''
    run-shell ${pkgs.tmuxPlugins.fingers.rtp}
  '';

  programs.home-manager.enable = true;
}
