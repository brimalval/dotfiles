# Phase 4: home-manager places the dotfiles (replaces stow and the hand-made herdr-app links).
#
# Every entry links back to the checkout, not into the Nix store, so edits take effect at once
# and apps that write to their config (lazy-lock.json, opencode.json, keys.json) keep working.
# The path must be the main checkout: a worktree or a relative path would break or freeze the links.
#
# Adding a file: add a line here, `git add` it, then switch (Mac: `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix`;
# WSL: `home-manager switch --flake ~/Projects/dotfiles/nix`). Mac-only links sit under `lib.optionalAttrs isDarwin`.
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
  home.file = {
    ".zshenv".source = link ".zshenv";
    ".zshrc".source = link ".zshrc"; # sources .zshrc.common and .zshrc.<platform> from the repo itself
    ".tmux.conf".source = link ".tmux.conf";
  }
  // lib.optionalAttrs isDarwin {
    ".aerospace.toml".source = link ".aerospace.toml";
  }
  // lib.genAttrs (map (s: ".local/bin/${s}") scripts) (p: { source = link p; });

  xdg.configFile = {
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
  };

  # Not linked on purpose:
  # - .claude/mods: Claude Code loads them from the repo via CLAUDE_CODE_PLUGIN_DIRS.
  # - alacritty.yml, karabiner.json, kitty.conf.bak, starship-*.toml, mouseless.*: kept in the repo, unused.
  # - .config/herdr-app/patches: applied in place with apply.sh, never linked.
}
