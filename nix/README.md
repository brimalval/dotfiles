# Nix: pinned tools

A small flake that pins CLI tools to exact versions. Today it holds one: `agent-browser`, kept equal
to `PIN=` in `~/.local/bin/herdr-browser`. Background and the reasoning: [docs/cli-version-management.md](../docs/cli-version-management.md).

stow never links this folder into `~` (`^/nix` in `.stow-local-ignore`).

## Install

Run from the main checkout, so the profile points at `~/Projects/dotfiles/nix`, not a worktree:

```sh
nix profile add ~/Projects/dotfiles/nix#agent-browser   # lands at ~/.nix-profile/bin/agent-browser
brew uninstall agent-browser                            # Homebrew's copy wins every PATH race
exec zsh                                                # new shell: .zshenv sets HERDR_BROWSER_BIN
herdr-browser --version                                 # passes the version check
```

`.zshenv` sets `HERDR_BROWSER_BIN=$HOME/.nix-profile/bin/agent-browser` only when that file exists and
is executable. Otherwise it stays unset and herdr-browser falls back to `command -v agent-browser`.

## Bump the pin

When Herdr moves `PIN=`:

1. Edit `version` in `pkgs/agent-browser.nix`.
2. Get the new hash and paste it into `hash`:
   ```sh
   nix store prefetch-file --json https://github.com/vercel-labs/agent-browser/releases/download/v<NEW>/agent-browser-darwin-arm64
   ```
   Or set `hash = lib.fakeHash;`, build, and copy the `got:` hash from the error.
3. Check: `nix build ~/Projects/dotfiles/nix#agent-browser && ./result/bin/agent-browser --version`.
4. `nix profile upgrade agent-browser`, then commit.

`nix flake update` refreshes nixpkgs in `flake.lock`. The pinned binary doesn't depend on it, so
only do that when you want to.

## Roll back

```sh
nix profile rollback          # back to the previous profile generation
nix profile history           # see the generations
```

To leave Nix for this tool: `nix profile remove agent-browser`, then install it some other way
(e.g. `npm i -g agent-browser@<PIN>`).
