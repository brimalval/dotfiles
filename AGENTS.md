# Notes for agents

- Shell: `ls` and `cat` are aliased to eza and bat. In scripts use `command ls` / `command cat`.
- GitHub: `gh`'s active account can't open or merge PRs on brimalval/dotfiles. Prefix that one command with `GH_TOKEN=$(gh auth token -u brimalval)`; never switch accounts or print the token.
- Linking: home-manager places every dotfile (`nix/links.nix`, links back into this checkout); stow is retired. New file: add a line there, `git add`, then the user runs `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix`. `~/.local/bin` is a real folder: tracked scripts in `.local/bin` are linked in one by one, installers' links (claude, codex, herdr) live only there.
- Herdr layouts are runtime-written by Shepherdr's panel mods: never symlink them into the repo. The look is applied by `.local/bin/herdr-layout-look`.
- Herdr caches layout background images by path for the window's life; only a new path or an app restart shows a new image.
- Shepherdr mod fixes live as patches in `.config/herdr-app/patches/shepherdr/` (run in place with `apply.sh`, never linked).
- Nix (Determinate) is at `/nix/var/nix/profiles/default/bin/nix`; shells started before its install lack it on PATH. Quote flake refs in zsh (`'path#attr'`).
- The machine is declared in `nix/`; read `nix/README.md` (setup, change workflow, recipes, troubleshooting) before changing packages, links, macOS settings or Homebrew. Homebrew is in zap mode: anything not listed in `nix/darwin.nix` is uninstalled on the next switch. No version managers: per-project versions use `nix flake init -t ~/Projects/dotfiles/nix#node` (or `#rust`) plus direnv.
- Commit straight to `main` here; no branches or PRs. Switches need sudo: hand `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix` to the user to run in a terminal pane.
- `codex exec`'s default model fails on this account; use a Claude subagent as reviewer.
- Orca orchestration workers: give hands-on workers their own `--worktree new-top-level` and keep their state under it. Exceptions (real config, global installs, writes outside the worktree) go to the user through `orchestration ask`. In those workers, run `claude` with the real HOME and XDG_DATA_HOME: when redirected, Claude installs a copy there and the shared daemon (`~/.claude/daemon.json`) starts spawning spares from it, which only `claude daemon stop` undoes, interrupting every daemon-hosted session.
- Orca rewrites Claude's statusLine and hooks in `~/.claude/settings.json` and `~/.codex/hooks.json`. If home-manager ever manages those files, merge at activation instead of linking.
- `orca computer` can report Accessibility as granted while calls fail: toggle "Orca Computer Use" off and on in Accessibility. Screen Recording needs an Orca restart. `screencapture -l` draws translucent windows over flat gray, so blur needs a region capture.
- Terminal and orchestration tool choices, and why: `docs/agent-terminals.md`.
