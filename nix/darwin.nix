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

  # Homebrew, declared. Phase 1 mirrored `brew list --installed-on-request` and the casks on
  # 2026-11-09; phase 2 moved the CLI formulae to home.nix. Activation installs what's missing and
  # touches nothing else: no update, no upgrade, no removal. Phase 3 dropped fnm.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # later: "zap" removes anything not listed here
    };

    taps = [
      "nikitabobko/tap" # aerospace
    ];

    # Phase 2 moved the CLI formulae to home.nix. Removing a line here doesn't uninstall it
    # (cleanup = "none"); `brew uninstall` does, after the switch.
    brews = [
      "railway" # nixpkgs lags far behind (5.30 vs 5.62)

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
