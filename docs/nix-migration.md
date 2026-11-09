# Moving this Mac onto Nix

History and decisions, 2026-11-06 to 2026-11-09. For how the setup works today and how to change it, see
[nix/README.md](../nix/README.md). The earlier research is in [cli-version-management.md](cli-version-management.md).

## Starting point

- CLI tools from Homebrew (33 formulae, 7 casks, 4 taps).
- Node from fnm (5 versions), Rust from rustup, bun from its own installer, Pythons downloaded by uv.
  Leftover setup for pyenv, pgenv and rv, none of them installed.
- Dotfiles linked by stow, plus six herdr-app links made by hand. `~/.local/bin` was a symlink into the repo,
  so installers (claude, codex, Herdr) wrote their links into the repo.
- The trigger: Herdr's `herdr-browser` needs agent-browser at exactly 0.41.1, and Homebrew shipped 0.41.2.

## Timeline

| When | Step | Commit |
|---|---|---|
| 11-06 | Research: Nix over mise, starting with one tool | #3 |
| 11-06 | agent-browser pinned with a one-package flake (`nix profile`) | #4 |
| 11-09 | Phase 1: nix-darwin + home-manager, describing the machine with no visible change | #7 |
| 11-09 | Phase 2: 30 CLI formulae from Homebrew to `home.packages` | #8 |
| 11-09 | Phase 3: version managers retired | `1c4aa0c` |
| 11-09 | Phase 4: dotfile links from home-manager, stow retired | `23f5cb3` |
| 11-09 | Phase 5: macOS settings, fonts, gcloud from Nix | `b10d8c4` |
| 11-09 | Phase 6: Homebrew `cleanup = "zap"` | `2c02114` |

From phase 3 on, changes went straight to `main` without PRs.

## Decisions

**Structure.** nix-darwin with home-manager as a module, rather than home-manager alone, because casks,
macOS settings and launchd are a large part of this machine. `nix.enable = false`: Determinate Nix runs the
daemon.

**Phase 1 changed nothing on purpose.** nix-darwin replaces `/etc/zshrc`, `/etc/zprofile` and friends, and
its zprofile doesn't run `path_helper`. `darwin.nix` lists every `/etc/paths(.d)` entry and LANG, turns off
nix-darwin's compinit and prompt (`.zshrc.common` has its own), and keeps Nix on the macOS keychain CA bundle.

**railway stays on Homebrew.** nixpkgs had 5.30 against brew's 5.62.

**pnpm 11, not nixpkgs' default 12,** to avoid a lockfile-format bump in existing projects.

**No version managers at all**, including rustup. Defaults in `home.nix`, per-project versions through
devShell templates (`#node`, `#rust`). Python 3.8 was dropped (end of life, unused). uv stays for packages,
with `UV_PYTHON_DOWNLOADS=never`.

**Dotfiles link back into the checkout** (`mkOutOfStoreSymlink`) instead of being copied into the store, so
edits stay live and apps that write their config (lazy.nvim, opencode, Herdr's keys.json) keep working.
starship.toml now lands in `~/.config`; stow had put it at `~/starship.toml`, where starship never looked.
Dead links (alacritty, karabiner, starship variants) were dropped, and their files kept.

**macOS settings declared exactly as they were.** Every value the first switch wrote matched the old one.

**Postgres stays a Homebrew service.** It holds 34 work databases; moving it meant a dump, restore and
collation risk for little gain.

**gcloud and the Maple Mono fonts moved to Nix.**

## What went wrong, and the fixes

- **`~/.zprofile` ran `brew shellenv`** (not in the repo), putting Homebrew back in front of Nix after phase 2.
  The line was replaced with a comment.
- **tmux-fingers:** nixpkgs bakes its binary path into the plugin script instead of putting `tmux-fingers` on
  PATH, so TPM's copy couldn't find it. tmux now loads the Nix plugin from
  `~/.local/share/tmux/nix-plugins.conf`.
- **Deletes and merges were blocked** by Claude Code's safety checks a few times, and sudo can't run from the
  `!` prefix. The user ran those steps in a terminal pane; the phase 4 cutover was a script with automatic
  restore.
- **brew's python@3.14 vanished** when the gcloud-cli cask was uninstalled (`brew uninstall` removes orphaned
  dependencies immediately). Three virtualenvs broke: viber-mcp (rebuilt with `uv sync`), gcloud's own
  (recreated), and a tenor worktree (repointed with `uv venv --allow-existing`, packages kept).
- **The first phase 6 switch didn't activate.** `brew cleanup` exited 1 on a cask from an untrusted tap
  (Homebrew 7 tap trust), which aborted activation after the new generation was registered. Fixed by declaring
  the tap `trusted = true`.

## Open at the end

- `~/.local/bin/claude` points into an Orca trial workspace (`~/orca/workspaces/dotfiles/trial-tuios/...`),
  rewritten by a Claude install running there. Repoint it at `~/.local/share/claude/versions/<version>` when
  that research is done.
- The walkthrough page with the same history: https://claude.ai/artifact/GEcE4uTHYJb2ov4YtoF556
