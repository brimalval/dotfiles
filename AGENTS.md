# Notes for agents

- Shell: `ls` and `cat` are aliased to eza and bat. In scripts use `command ls` / `command cat`.
- GitHub: `gh`'s active account can't open or merge PRs on brimalval/dotfiles. Prefix that one command with `GH_TOKEN=$(gh auth token -u brimalval)`; never switch accounts or print the token.
- Linking: herdr-app pieces are linked into `~/.config/herdr-app` by hand with `ln -sfn` (see `.config/herdr-app/README.md`), not stow. `~/.local/bin` is a symlink to this repo's `.local/bin`.
- Herdr layouts are runtime-written by Shepherdr's panel mods: never symlink them into the repo. The look is applied by `.local/bin/herdr-layout-look`.
- Herdr caches layout background images by path for the window's life; only a new path or an app restart shows a new image.
- Shepherdr mod fixes live as patches in `.config/herdr-app/patches/shepherdr/` (run in place with `apply.sh`, never linked).
- Nix (Determinate) is at `/nix/var/nix/profiles/default/bin/nix`; shells started before its install lack it on PATH. Quote flake refs in zsh (`'path#attr'`).
- Test stow ignores with `stow -n -v` into a scratch target.
- `codex exec`'s default model fails on this account; use a Claude subagent as reviewer.
