# Nix: this Mac, declared

`flake.nix` describes the machine in layers. The plan and the reasoning behind it:
[docs/cli-version-management.md](../docs/cli-version-management.md).

| File | Layer | Owns today |
|---|---|---|
| `darwin.nix` | nix-darwin (system) | `/etc/zsh*` and `/etc/bashrc`, system PATH, what's left on Homebrew (casks, railway, docker, postgres) |
| `home.nix` | home-manager (user), run inside nix-darwin | CLI packages and toolchains, session variables, direnv, the tmux-fingers snippet |
| `links.nix` | home-manager | every dotfile link, pointing back into this checkout |
| `pkgs/agent-browser.nix` | own package | agent-browser pinned for Herdr, installed with `nix profile` |

## Dotfile links

`links.nix` lists every link. Each points back into this checkout (`mkOutOfStoreSymlink`), so edits take
effect at once and apps can write to their config. To add one, add a line, `git add` the file, and switch.
To remove one, delete the line and switch; home-manager removes the link. Every git-tracked file in
`.local/bin` is linked into a real `~/.local/bin` automatically.

A flake only sees files git tracks: an untracked new config fails the build with "file not found".

## Migration phases

1. nix-darwin with no visible change. Done 2026-11-09.
2. CLI formulae move from `homebrew.brews` to `home.packages`. Done 2026-11-09: 30 formulae; railway stays on
   brew (nixpkgs lags far behind). tmux-fingers loads from `~/.local/share/tmux/nix-plugins.conf`.
3. Retire version managers. Done 2026-11-09. No fnm, rustup, pyenv, pgenv, rv, bun installer or uv-downloaded
   Pythons. `home.nix` has the defaults: Node 26, pnpm 11, bun, Python 3.14, uv, Rust (rustc, cargo, clippy,
   rustfmt, rust-analyzer) and `tms`. `home.sessionVariables` reach every shell through `~/.zshenv`
   (`UV_PYTHON_DOWNLOADS=never`, `RUST_SRC_PATH`, `NPM_CONFIG_PREFIX`). For other versions in a project:
   ```sh
   nix flake init -t ~/Projects/dotfiles/nix#node   # or #rust (reads rust-toolchain.toml)
   # edit the versions in flake.nix, then:
   direnv allow
   ```
4. Dotfile links from home-manager. Done 2026-11-09: stow and the hand-made herdr-app links
   replaced by `links.nix`; `~/.local/bin` is a real folder. starship.toml now lands in `~/.config`, where
   starship reads it. Dead links (alacritty, karabiner, starship variants) dropped; the files stay in the repo.
5. macOS settings, fonts, gcloud. Done 2026-11-09: `system.defaults` declares the settings as
   they were (key repeat, dark mode, Dock, Finder, trackpad, Stage Manager); change them in `darwin.nix`, not
   System Settings, or the next switch reverts them. Maple Mono fonts and gcloud (with the GKE auth plugin) come
   from Nix. Postgres stays a Homebrew service on purpose (34 work databases in /opt/homebrew/var/postgresql@18).
   brew's python@3.14 left with the gcloud cask; the virtualenvs that used it were moved to Nix's 3.14.
6. **`homebrew.onActivation.cleanup = "zap"`** ← you are here. Done 2026-11-09. Each switch uninstalls any brew
   formula, cask or tap not listed in `darwin.nix` (casks also lose their app-support files). The dry run
   before turning it on removed nothing installed; only stale download caches. Third-party taps must be
   declared `{ name = ...; trusted = true; }`: Homebrew 7 refuses their casks otherwise, and the cleanup step
   fails the whole activation (the new generation is registered but `/run/current-system` stays on the old one).

## First switch (one-off)

Run from the main checkout. A flake only sees files git tracks, so commit (or `git add`) first.

```sh
# nix-darwin won't overwrite /etc files it doesn't recognise. Keep macOS's/Determinate's copies:
sudo mv /etc/zshrc   /etc/zshrc.before-nix-darwin
sudo mv /etc/zshenv  /etc/zshenv.before-nix-darwin
sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin
sudo mv /etc/bashrc  /etc/bashrc.before-nix-darwin

# darwin-rebuild isn't installed yet; run the locked nix-darwin once to install it:
sudo nix run 'github:nix-darwin/nix-darwin/ff0e21a#darwin-rebuild' -- switch --flake ~/Projects/dotfiles/nix
exec zsh
```

Then check:
- `echo $PATH`: Nix profiles, then `/opt/homebrew/bin`, then the system dirs.
- `which nix darwin-rebuild agent-browser`, and that `herdr-browser --version` still passes.
- `brew services list`: postgres is still running.

What changes on the first switch:
- nix-darwin generates `/etc/zshenv`, `/etc/zprofile`, `/etc/zshrc` and `/etc/bashrc`. They set PATH
  directly instead of running `path_helper`. `darwin.nix` lists every `/etc/paths` and `/etc/paths.d` entry,
  plus LANG, so nothing goes missing. compinit and the prompt stay in `.zshrc.common`.
- `brew bundle` runs. Everything is already installed, so it only checks. No update, upgrade or removal.
- nix-darwin adds a few files of its own under `/etc/ssh`, `/etc/pam.d/sudo_local` and `/etc/sudoers.d`.
  None of them exist today.

## Everyday use

```sh
sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix   # apply changes
darwin-rebuild build --flake ~/Projects/dotfiles/nix         # build only, to check
sudo darwin-rebuild --rollback                               # back to the previous generation
nix flake update --flake ~/Projects/dotfiles/nix             # refresh nixpkgs, nix-darwin, home-manager
```

To add a cask or formula: list it in `darwin.nix`, then switch. A plain `brew install` works until the next
switch, which uninstalls it (cleanup = "zap"). Prefer nixpkgs in `home.nix` when the package is there.
To preview what a switch would remove: `brew bundle cleanup --file=$(grep -o '/nix/store/[^ "]*Brewfile' /run/current-system/activate | head -1)`.

Uninstall nix-darwin: `sudo darwin-uninstaller`. Then restore the `.before-nix-darwin` files.

## Python virtualenvs after a Python update

Virtualenvs record the interpreter path. uv-made ones point at `/etc/profiles/per-user/brian/bin` and keep
working across patch releases; a new minor (3.14 → 3.15) needs `uv sync` (or `uv venv --allow-existing`).
gcloud's own virtualenv points at gcloud's exact Nix Python, so after `nix flake update` and a switch run:

```sh
gcloud config virtualenv delete --quiet && gcloud config virtualenv create
```

## agent-browser pin

Installed outside nix-darwin for now. `.zshenv` sets `HERDR_BROWSER_BIN` to
`~/.nix-profile/bin/agent-browser` when that file exists. It moves into `home.nix` in phase 2.

Install: `nix profile add ~/Projects/dotfiles/nix#agent-browser` (then `brew uninstall agent-browser`).

When Herdr moves `PIN=` in `~/.local/bin/herdr-browser`:

1. Edit `version` in `pkgs/agent-browser.nix`.
2. Get the new hash and paste it into `hash`:
   ```sh
   nix store prefetch-file --json https://github.com/vercel-labs/agent-browser/releases/download/v<NEW>/agent-browser-darwin-arm64
   ```
   Or set `hash = lib.fakeHash;`, build, and copy the `got:` hash from the error.
3. Check: `nix build ~/Projects/dotfiles/nix#agent-browser && ./result/bin/agent-browser --version`.
4. `nix profile upgrade agent-browser`, then commit.

Roll back with `nix profile rollback`.
