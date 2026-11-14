# Mac-only user layer (home-manager inside nix-darwin). Shared packages and settings: home.nix.
# Packages land in /etc/profiles/per-user/brian/bin, ahead of Homebrew on PATH.
{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  home.username = "brian";
  home.homeDirectory = "/Users/brian";

  home.packages = with pkgs; [
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

    blueutil
  ];
  # Stays on Homebrew (darwin.nix): railway (nixpkgs is ~30 releases behind), docker, postgresql@18.
  # agent-browser stays in `nix profile` until HERDR_BROWSER_BIN moves; see README.

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
    # Option+F full-width column (Control+Option+Shift+F fullscreen), Option+Tab previous workspace, Option+Shift+Q close, Option+Shift+F float,
    # Option+/ layout, Option+Shift+Tab workspace to the right monitor. Borders off (square; windows are rounded). Workspaces 10 and 11 show as
    # D and S (names must be numbers) on Option+D / Option+S; Discord and Slack open there.
    # OmniWM's Settings window rewrites the live file and the next switch puts this one back:
    # copy changes you want to keep into nix/omniwm/settings.toml.
    settings = ./omniwm/settings.toml;
  };
}
