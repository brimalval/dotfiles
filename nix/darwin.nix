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

  # nix-darwin's default is EDITOR=nano, exported from /etc/zshenv before ~/.zshenv runs.
  # Claude Code's Ctrl+G and git prefer VISUAL, so set both.
  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";

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

  # macOS settings, declared exactly as they were on 2026-11-09 (phase 5): switching changes nothing
  # on screen, and a new Mac comes out the same. Change them here, not in System Settings, or the
  # next switch puts them back.
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 25;
      AppleInterfaceStyle = "Dark";
      "com.apple.swipescrolldirection" = false; # natural scrolling off
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
    };
    dock = {
      autohide = true;
      tilesize = 60;
      wvous-br-corner = 14; # bottom-right hot corner: Quick Note
    };
    finder = {
      FXPreferredViewStyle = "clmv"; # column view
      ShowExternalHardDrivesOnDesktop = true;
    };
    WindowManager = {
      GloballyEnabled = false; # Stage Manager off
      EnableTiledWindowMargins = false;
    };
    trackpad = {
      Clicking = false; # tap to click off
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };
  };

  # Fonts land in /Library/Fonts/Nix Fonts. Same family names as the old casks, so terminal and
  # editor configs don't change.
  fonts.packages = [
    pkgs.maple-mono.variable # was cask font-maple-mono
    pkgs.maple-mono.NF # was cask font-maple-mono-nf
  ];

  # Homebrew, declared. Phase 1 mirrored `brew list --installed-on-request` and the casks on
  # 2026-11-09; phase 2 moved the CLI formulae to home.nix. Activation installs what's missing and
  # touches nothing else: no update, no upgrade, no removal. Phase 3 dropped fnm.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Phase 6: anything installed with brew but not listed below is uninstalled on the next switch
      # (casks also lose their app-support files). To keep a new tool, list it here first.
      cleanup = "zap";
    };

    taps = [
      # aerospace. Homebrew 7 refuses casks from untrusted third-party taps, and `brew cleanup`
      # (run by cleanup = "zap") failed on it until the tap itself was marked trusted.
      { name = "nikitabobko/tap"; trusted = true; }
    ];

    # Everything else comes from Nix (home.nix). Removing a line here uninstalls it on the next switch.
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
      "google-chrome"
      "mouseless@preview"
    ];

    # Mac App Store apps, installed by `mas` (nix-darwin supplies it). Needs an App Store sign-in.
    # Once this list is non-empty, zap cleanup also tries to uninstall App Store apps NOT listed here
    # (nix-darwin's docs say otherwise; Homebrew Bundle now does it). List every App Store app you keep.
    # `mas list` shows what's installed.
    masApps = {
      Xcode = 497799835; # iOS builds for tenor-mobile; needs macOS 26.6+
      Numbers = 361304891;
      Pages = 361309726;
      PDFgear = 6469021132;
    };
  };
}
