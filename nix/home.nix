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
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ]) # was cask gcloud-cli
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
    libfaketime
    blueutil
  ];
  # Stays on Homebrew (darwin.nix): railway (nixpkgs is ~30 releases behind), docker, postgresql@18.
  # agent-browser stays in `nix profile` until HERDR_BROWSER_BIN moves; see README.

  # Java 17 on PATH plus JAVA_HOME, which Gradle, Maestro and project scripts look for
  # (without it, agents conclude there's no JDK and reach for brew's openjdk@17).
  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  # OmniWM (trial, replacing AeroSpace, which crashes on `focus` over floating windows: upstream #1311;
  # a fix is kept in aerospace/patches/ in case we go back). home-manager runs it from a launchd agent
  # that starts it at login and restarts it if it exits. AeroSpace stays installed but isn't started:
  # only one window manager can run at a time.
  programs.omniwm = {
    enable = true;
    # nixpkgs is at 0.7.6; v0.8.0 is the developer's signed, notarized release.
    package = pkgs.omniwm.overrideAttrs (finalAttrs: _: {
      version = "0.8.0";
      src = pkgs.fetchurl {
        url = "https://github.com/OmniNull/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
        hash = "sha256-b3+z4hHeOoPncrExgAaAyz0g1MY4gRofAhIP0iXwPMc=";
      };
    });
    # The whole file, not just our changes: the schema is strict and rejects a partial file.
    # Started from OmniWM 0.8.0's defaults with AeroSpace habits: Option+H/J/K/L focus (+Shift moves),
    # Option+F fullscreen, Option+Tab previous workspace, Option+Shift+Q close, Option+Shift+F float,
    # Option+/ layout, Option+Shift+Tab workspace to the right monitor. Borders off (square; windows are rounded). Workspaces 10 and 11 show as
    # D and S (names must be numbers) on Option+D / Option+S; Discord and Slack open there.
    # OmniWM's Settings window rewrites the live file and the next switch puts this one back:
    # copy changes you want to keep into nix/omniwm/settings.toml.
    settings = ./omniwm/settings.toml;
  };

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
