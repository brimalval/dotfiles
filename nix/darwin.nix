# System layer (nix-darwin). Phase 1: describe the machine as it is, change nothing visible.
# Apply: sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix
{ lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true; # terraform (BSL) and others, once they move off brew

  # Determinate Nix runs the daemon and owns /etc/nix/nix.conf. nix-darwin must not.
  nix.enable = false;

  # Same CA bundle Determinate's nix.conf uses (ssl-cert-file): the macOS keychain, so any
  # system-trusted CA (e.g. a VPN's) keeps working. nix-darwin's default is a nixpkgs bundle.
  environment.variables.NIX_SSL_CERT_FILE = "/etc/nix/macos-keychain.crt";

  system.primaryUser = "brian"; # homebrew and system.defaults act as this user
  users.users.brian.home = "/Users/brian";

  system.stateVersion = 7; # set once at first install; don't bump

  # nix-darwin takes over /etc/zshenv, /etc/zprofile and /etc/zshrc. Keep what macOS's versions did
  # and leave the rest to ~/.zshrc.common (compinit, history, keymap, prompt).
  programs.zsh = {
    enable = true;
    enableCompletion = false; # .zshrc.common runs `compinit -C`; don't run it twice
    enableBashCompletion = false;
    promptInit = ""; # starship
    # macOS's /etc/zprofile did this.
    loginShellInit = ''
      if [ -z "$LANG" ]; then export LANG=C.UTF-8; fi
    '';
  };

  # macOS's /etc/zprofile ran path_helper, which read /etc/paths and /etc/paths.d. nix-darwin's
  # doesn't, so list those entries here. Order: Nix profiles, then Homebrew, then the system.
  environment.systemPath = lib.mkMerge [
    (lib.mkOrder 1100 [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ])
    (lib.mkOrder 1300 [
      "/System/Cryptexes/App/usr/bin"
      "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
      "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
      "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
      "/pkg/env/global/bin"
    ])
  ];

  # Homebrew, declared. Mirrors `brew list --installed-on-request` and `brew list --cask` on
  # 2026-11-09. Phase 1 installs what's missing and touches nothing else: no update, no upgrade,
  # no removal. Phase 2 moves the CLI formulae into home.nix one batch at a time.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # later: "zap" removes anything not listed here
    };

    taps = [
      "hashicorp/tap"
      "morantron/tmux-fingers"
      "nats-io/nats-tools"
      "nikitabobko/tap"
    ];

    brews = [
      # Phase 2 candidates: all in nixpkgs.
      "actionlint"
      "blueutil"
      "chafa"
      "cloudflared"
      "eza"
      "ffmpeg"
      "flyctl"
      "fzf"
      "gh"
      "git-filter-repo"
      "hashicorp/tap/terraform" # nixpkgs: unfree (allowed above)
      "helm"
      "imagemagick"
      "lazygit"
      "libfaketime"
      "nats-io/nats-tools/nats"
      "nats-server"
      "neovim"
      "openjdk@17"
      "poppler"
      "railway"
      "ripgrep"
      "starship"
      "stow" # goes away in phase 4
      "tmux"
      "morantron/tmux-fingers/tmux-fingers" # nixpkgs: tmuxPlugins.fingers
      "tree-sitter"
      "tree-sitter-cli"
      "uv"
      "whisper.cpp"
      "yazi"
      "zoxide"

      # Phase 3 removes it, along with rustup and the other version managers (see README).
      "fnm"

      # Staying on brew for now.
      "docker" # CLI for Docker Desktop
      {
        name = "postgresql@18";
        restart_service = "changed"; # runs as homebrew.mxcl.postgresql@18 today
      }
    ];

    casks = [
      "aerospace"
      "android-commandlinetools"
      "font-maple-mono"
      "font-maple-mono-nf"
      "gcloud-cli"
      "google-chrome"
      "mouseless@preview"
    ];
  };
}
