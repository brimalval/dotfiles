# Notes for agents

- Shell: `ls` and `cat` are aliased to eza and bat. In scripts use `command ls` / `command cat`.
- GitHub: `gh`'s active account can't open or merge PRs on brimalval/dotfiles. Prefix that one command with `GH_TOKEN=$(gh auth token -u brimalval)`; never switch accounts or print the token.
- Linking: home-manager places every dotfile (`nix/links.nix`, links back into this checkout); stow is retired. New file: add a line there, `git add`, then the user runs `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix`. `~/.local/bin` is a real folder: tracked scripts in `.local/bin` are linked in one by one, installers' links (claude, codex, herdr) live only there.
- Herdr layouts are runtime-written by Shepherdr's panel mods: never symlink them into the repo. The look is applied by `.local/bin/herdr-layout-look`.
- Herdr caches layout background images by path for the window's life; only a new path or an app restart shows a new image.
- Shepherdr mod fixes live as patches in `.config/herdr-app/patches/shepherdr/` (run in place with `apply.sh`, never linked).
- Nix (Determinate) is at `/nix/var/nix/profiles/default/bin/nix`; shells started before its install lack it on PATH. Quote flake refs in zsh (`'path#attr'`).
- Packages come from `nix/home.nix` (Homebrew keeps only casks, docker, postgres, railway). No version managers: per-project versions use `nix flake init -t ~/Projects/dotfiles/nix#node` (or `#rust`) plus direnv.
- `codex exec`'s default model fails on this account; use a Claude subagent as reviewer.
