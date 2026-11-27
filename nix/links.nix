# Phase 4: home-manager places the dotfiles (replaces stow and the hand-made herdr-app links).
#
# Every entry links back to the checkout, not into the Nix store, so edits take effect at once
# and apps that write to their config (lazy-lock.json, opencode.json, keys.json) keep working.
# The path must be the main checkout: a worktree or a relative path would break or freeze the links.
#
# Adding a file: add a line here, `git add` it, then switch (Mac: `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix`;
# WSL: `home-manager switch --flake ~/Projects/dotfiles/nix`; NixOS: `sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix`).
# Mac-only links sit under `lib.optionalAttrs isDarwin`, the Linux desktop's under `config.dotfiles.linuxDesktop`.
# Removing one: delete the line and switch; home-manager removes the link.
{ config, lib, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/Projects/dotfiles";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";

  # Every git-tracked file in .local/bin, linked one by one into a real ~/.local/bin.
  # (Installers like claude, codex and Herdr drop their own links there; they stay out of the repo.)
  scripts = lib.attrNames (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ../.local/bin));
in
{
  # Set by the bare-metal NixOS desktop (home-nixos-desktop.nix): links the Hyprland session's configs.
  options.dotfiles.linuxDesktop = lib.mkEnableOption "the Linux desktop's (Hyprland) config links";

  config.home.file = {
    ".zshenv".source = link ".zshenv";
    ".zshrc".source = link ".zshrc"; # sources .zshrc.common and .zshrc.<platform> from the repo itself
    ".tmux.conf".source = link ".tmux.conf";
  }
  // lib.optionalAttrs isDarwin {
    ".aerospace.toml".source = link ".aerospace.toml";
    ".claude/CLAUDE.md".source = link ".claude/global/CLAUDE.md"; # user-level rules for Orca coordinators, shared by every agent
    ".codex/AGENTS.md".source = link ".claude/global/CLAUDE.md"; # same rules for Codex; OpenCode gets them via .config/opencode/AGENTS.md
  }
  // lib.genAttrs (map (s: ".local/bin/${s}") scripts) (p: { source = link p; });

  config.xdg.configFile = {
    # Whole folders
    "nvim".source = link ".config/nvim";
    "opencode".source = link ".config/opencode";
    "tmux".source = link ".config/tmux";
    "yazi".source = link ".config/yazi";

    # Single files
    "starship.toml".source = link "starship.toml"; # was linked to ~/starship.toml, which starship never read
    "kitty/kitty.conf".source = link ".config/kitty/kitty.conf";
    "herdr/config.toml".source = link ".config/herdr/config.toml";
  }
  // lib.optionalAttrs isDarwin {
    # herdr-app: only these pieces. Layouts other than my-main.json are written at runtime by
    # Herdr/Shepherdr and must stay plain files (see .config/herdr-app/README.md).
    "herdr-app/settings.json".source = link ".config/herdr-app/settings.json";
    "herdr-app/keys.json".source = link ".config/herdr-app/keys.json";
    "herdr-app/layouts/my-main.json".source = link ".config/herdr-app/layouts/my-main.json";
    "herdr-app/themes/rose-pine-moon.json".source = link ".config/herdr-app/themes/rose-pine-moon.json";
    "herdr-app/mods/nvim-nav".source = link ".config/herdr-app/mods/nvim-nav";
    "herdr-app/mods/lazygit-popup".source = link ".config/herdr-app/mods/lazygit-popup";
  }
  // lib.optionalAttrs config.dotfiles.linuxDesktop {
    "hypr".source = link ".config/hypr"; # hyprland.lua, hypridle.conf, hyprlock.conf
    "mako/config".source = link ".config/mako/config"; # notification popups
    "kitty/linux.conf".source = link ".config/kitty/linux.conf"; # smaller font_size than the Mac
    "waybar".source = link ".config/waybar"; # config.jsonc, style.css, corners/
  };

  config.xdg.dataFile = lib.optionalAttrs config.dotfiles.linuxDesktop {
    "vicinae/scripts".source = link ".config/vicinae/scripts"; # Vicinae script commands (Hyprland actions)
  };

  # Not linked on purpose:
  # - .claude/mods: Claude Code loads them from the repo via CLAUDE_CODE_PLUGIN_DIRS.
  # - alacritty.yml, karabiner.json, kitty.conf.bak, starship-*.toml, mouseless.*: kept in the repo, unused.
  # - .config/herdr-app/patches: applied in place with apply.sh, never linked.
}
