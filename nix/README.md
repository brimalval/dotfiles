# Nix: this Mac, declared

`flake.nix` describes the machine in layers. The plan and the reasoning behind it:
[docs/cli-version-management.md](../docs/cli-version-management.md).

| File | Layer | Owns today |
|---|---|---|
| `darwin.nix` | nix-darwin (system) | `/etc/zsh*` and `/etc/bashrc`, system PATH, the Homebrew list (taps, formulae, casks) |
| `home.nix` | home-manager (user), run inside nix-darwin | nothing yet: wired up, empty |
| `pkgs/agent-browser.nix` | own package | agent-browser pinned for Herdr, installed with `nix profile` |

stow still places the dotfiles and never links this folder into `~` (`^/nix` in `.stow-local-ignore`).

## Migration phases

1. **nix-darwin with no visible change** ← you are here. Homebrew is declared but not otherwise touched.
2. CLI formulae move from `homebrew.brews` to `home.packages`, a batch at a time. Before this phase,
   remove the `/opt/homebrew/bin` prepend in `.zshrc.mac`, or Homebrew's copies win in interactive shells.
3. Retire version managers. Nix supplies the default toolchains, and each project's devShell (loaded by
   nix-direnv) supplies its own versions:
   - fnm goes (brew formula and its setup in `.zshenv`, `.zshrc`, `.zshrc.common`, the `.nvmrc` hook in
     `.zshrc.mac`). Node and pnpm come from Nix.
   - rustup goes (`~/.rustup`, `~/.cargo`, `.zshenv`'s `.cargo/env`). Rust comes from nixpkgs, and
     `rust-overlay` in a devShell handles a project that pins a toolchain. Cargo-installed tools like `tms`
     move to nixpkgs.
   - pyenv's leftover setup in `.zshrc.common` is deleted (pyenv isn't installed).
   - bun's own install in `~/.bun` is replaced by `pkgs.bun`.
   - uv stays for packages and venvs, but stops downloading Pythons (`UV_PYTHON_DOWNLOADS=never`). Python
     comes from Nix. Its downloaded interpreters (3.8, 3.12, 3.13) and `~/.local/bin/python3.8` are removed.
   - A devShell template goes in this flake: `nix flake init -t ~/Projects/dotfiles/nix#node`.
4. Dotfiles: stow replaced by `home.file` / `xdg.configFile` with `mkOutOfStoreSymlink` (edits stay live).
   `~/.local/bin` becomes a real directory again.
5. `system.defaults`, fonts, launchd services (postgres last).
6. `homebrew.onActivation.cleanup = "zap"`.

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

To add a cask or formula: list it in `darwin.nix`, then switch. Installing with `brew install` still works,
but the tool isn't in the config until you list it.

Uninstall nix-darwin: `sudo darwin-uninstaller`. Then restore the `.before-nix-darwin` files.

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
