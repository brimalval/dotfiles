# Nix: this Mac, declared

This folder describes the whole machine: packages, toolchains, dotfile links, macOS settings and the
Homebrew list. Edit it, switch, and the Mac matches. How it got this way: [docs/nix-migration.md](../docs/nix-migration.md).

- [Current setup](#current-setup)
- [Making a change](#making-a-change)
- [Recipes](#recipes)
- [Troubleshooting](#troubleshooting)

## Current setup

### Where things come from

| What | From | Declared in |
|---|---|---|
| CLI tools (rg, nvim, gh, yazi, tmux, terraform, ...) | nixpkgs | `home.nix` → `home.packages` |
| Toolchains: Node 26, pnpm 11, bun, Python 3.14, uv, Rust, Java 17 | nixpkgs | `home.nix` |
| Per-project versions | a devShell in the project, loaded by direnv | the project's `flake.nix` (templates in `templates/`) |
| gcloud (+ bq, gsutil, GKE auth plugin), Maple Mono fonts | nixpkgs | `home.nix`, `darwin.nix` → `fonts.packages` |
| Dotfiles (`~/.zshrc`, `~/.config/nvim`, ...) | links back into this checkout | `links.nix` |
| Scripts in `~/.local/bin` | every git-tracked file in `../.local/bin`, linked | `links.nix` (automatic) |
| macOS settings (key repeat, Dock, Finder, trackpad, ...) | nix-darwin | `darwin.nix` → `system.defaults` |
| Shell startup files in `/etc`, system PATH | nix-darwin | `darwin.nix` |
| docker, postgresql@18 (running service), railway | Homebrew | `darwin.nix` → `homebrew.brews` |
| aerospace, android-commandlinetools, google-chrome, mouseless | Homebrew casks | `darwin.nix` → `homebrew.casks` |
| agent-browser, pinned for Herdr | own package, `nix profile` | `pkgs/agent-browser.nix` |
| claude, codex, herdr, shepherdr, sprite | their own installers (they update themselves) | not managed; links sit in `~/.local/bin` |

### Files

| File | What it holds |
|---|---|
| `flake.nix` | Inputs (nixpkgs, nix-darwin, home-manager), the system for `Brians-MacBook-Pro`, packages, templates |
| `flake.lock` | The exact version of every input. `nix flake update` moves it |
| `darwin.nix` | System layer: `/etc` shell files, PATH, `system.defaults`, fonts, the Homebrew list |
| `home.nix` | User layer: packages, session variables, direnv, the tmux-fingers snippet |
| `links.nix` | Every dotfile link |
| `pkgs/` | Own packages (agent-browser) |
| `templates/` | devShell templates: `node`, `rust` |

### Rules to know

- **A switch is the only way changes land.** Editing a `.nix` file does nothing until
  `sudo darwin-rebuild switch --flake ~/Projects/dotfiles/nix`.
- **A flake only sees files git tracks.** A new file must be `git add`ed (committing isn't required) or the
  build fails with "file not found".
- **Homebrew is strict** (`cleanup = "zap"`): each switch uninstalls any formula, cask or tap not listed in
  `darwin.nix`. A plain `brew install` lasts until the next switch.
- **macOS settings in `system.defaults` win.** Change them in `darwin.nix`; a change made in System Settings is
  put back on the next switch. Settings not listed there are left alone.
- **Dotfile links point at the checkout**, not the Nix store, so edits to configs take effect at once and apps
  can write to them. The repo must stay at `~/Projects/dotfiles` (the path is in `links.nix`).
- **No version managers.** Defaults come from `home.nix`; anything else from a project devShell. uv never
  downloads Pythons (`UV_PYTHON_DOWNLOADS=never`).
- **PATH order:** `~/.local/bin` (installers' links, your scripts) → Nix profiles → Homebrew → system.
  Nothing may prepend Homebrew in front of Nix (see [Troubleshooting](#brews-copy-runs-instead-of-nixs)).
- **sudo needs a real terminal.** The `!` prefix in Claude Code and agents' shells can't answer the password
  prompt, so run switches in a terminal pane.

## Making a change

```sh
cd ~/Projects/dotfiles
$EDITOR nix/home.nix                                          # 1. edit
git add -A nix                                                # 2. new files must be tracked
darwin-rebuild build --flake ./nix                            # 3. optional: build only (no sudo), catches errors
nix store diff-closures /run/current-system ./result          #    optional: what changes, package by package
sudo darwin-rebuild switch --flake ./nix                      # 4. apply
exec zsh                                                      # 5. new shell picks up PATH/env changes
git commit -am "..." && git push                              # 6. commit straight to main
```

Undo the last switch:

```sh
sudo darwin-rebuild --rollback                 # previous generation
darwin-rebuild --list-generations              # all of them
sudo darwin-rebuild --switch-generation 7      # a specific one
```

A rollback restores packages, links and settings, but not files a switch deleted (Homebrew uninstalls, for
example). `git revert` the commit too, or the next switch reapplies it.

Preview what a switch would uninstall from Homebrew:

```sh
brew bundle cleanup --file="$(grep -o '/nix/store/[^ "]*Brewfile' /run/current-system/activate | head -1)"
```

That checks the active config. For an edited one, build first and point at
`./result/activate` instead of `/run/current-system/activate`.

## Recipes

### Add or remove a CLI tool

Find it: `nix search --inputs-from ~/Projects/dotfiles/nix nixpkgs <name>` (or
[search.nixos.org](https://search.nixos.org/packages)). `--inputs-from` searches the nixpkgs this flake has
locked, which is what a switch installs. Then add the attribute to `home.packages` in `home.nix` and switch.
Removing: delete the line and switch; it leaves PATH.

```nix
home.packages = with pkgs; [
  ripgrep
  jq          # new
];
```

Check the version first: `nix eval --raw --inputs-from ~/Projects/dotfiles/nix 'nixpkgs#jq.version'`. If nixpkgs lags far behind (railway did:
5.30 vs 5.62), either keep it on Homebrew (next recipe) or pin it yourself
([Pin a tool to an exact version](#pin-a-tool-to-an-exact-version)).

### Add a cask or a Homebrew-only formula

For GUI apps and anything nixpkgs lacks or lags on. Add it to `darwin.nix` and switch; the switch installs it.

```nix
homebrew = {
  casks = [ "aerospace" "google-chrome" "raycast" ];        # raycast is new
  brews = [ "railway" "docker" ];
  taps = [ { name = "nikitabobko/tap"; trusted = true; } ];
};
```

A cask or formula from a third-party tap needs that tap listed with `trusted = true`, or Homebrew 7 refuses it
and the switch fails ([details](#a-switch-registers-a-new-generation-but-the-machine-stays-on-the-old-one)).
Removing: delete the line and switch; zap mode uninstalls it, including its app-support files.

Before removing a Homebrew package by hand, see [brew uninstall removes more than asked](#brew-uninstall-removes-more-than-asked).

### Link a new dotfile

Add the file to the repo, add a line to `links.nix`, `git add` both, switch.

```nix
xdg.configFile."ghostty/config".source = link ".config/ghostty/config";   # ~/.config/ghostty/config
home.file.".gitconfig".source = link ".gitconfig";                       # ~/.gitconfig
xdg.configFile."wezterm".source = link ".config/wezterm";                # a whole folder
```

If the target already exists as a plain file, the switch moves it aside as `*.before-home-manager` first.
Don't link files an app rewrites with its own content at runtime (Herdr's layouts other than `my-main.json`).

### Add a script to `~/.local/bin`

Put it in `.local/bin/` in the repo, `chmod +x` it, `git add` it, switch. Every tracked file there is linked
automatically; nothing to add to `links.nix`.

### Per-project versions (Node, Rust)

In the project:

```sh
nix flake init -t ~/Projects/dotfiles/nix#node     # or #rust
$EDITOR flake.nix                                  # pick versions, e.g. nodejs_22, pnpm_10
direnv allow                                       # loads the shell now and on every cd
```

The Rust template follows the project's `rust-toolchain.toml` when there is one. Commit `flake.nix`,
`flake.lock` and `.envrc` in the project so everyone gets the same versions. Python projects need no template:
`uv sync` uses the Python from `home.nix`, or add `pkgs.python313` to a devShell for another version.

### Change a macOS setting

Set it in `system.defaults` in `darwin.nix` and switch. Find the option name in the
[nix-darwin options](https://nix-darwin.github.io/nix-darwin/manual/) (`system.defaults.*`). To find which
key System Settings writes, compare before and after:

```sh
defaults read > /tmp/before.txt     # change the setting in System Settings, then:
defaults read > /tmp/after.txt && diff /tmp/before.txt /tmp/after.txt
```

Keys nix-darwin has no option for go in `system.defaults.CustomUserPreferences."<domain>"."<key>"`.
Some settings (Dock, keyboard) need a logout or `killall Dock` to show.

### Pin a tool to an exact version

The agent-browser pattern: a small package in `pkgs/` that fetches one release binary. Use it when a tool
must match an exact version (Herdr's `herdr-browser` refuses anything but its `PIN=`).

To bump agent-browser when Herdr moves `PIN=` in `~/.local/bin/herdr-browser`:

1. Edit `version` in `pkgs/agent-browser.nix`.
2. Get the hash and paste it into `hash`:
   ```sh
   nix store prefetch-file --json https://github.com/vercel-labs/agent-browser/releases/download/v<NEW>/agent-browser-darwin-arm64
   ```
   Or set `hash = lib.fakeHash;`, build, and copy the `got:` hash from the error.
3. Check: `nix build ~/Projects/dotfiles/nix#agent-browser && ./result/bin/agent-browser --version`.
4. `nix profile upgrade agent-browser`, then commit. Undo with `nix profile rollback`.

agent-browser lives in `nix profile` (not `home.nix`) because `.zshenv` points `HERDR_BROWSER_BIN` at
`~/.nix-profile/bin/agent-browser`. A new pinned tool can go straight into `home.packages` as
`(pkgs.callPackage ./pkgs/<tool>.nix { })`.

### Update everything

```sh
cd ~/Projects/dotfiles
nix flake update --flake ./nix                       # newest nixpkgs, nix-darwin, home-manager
darwin-rebuild build --flake ./nix && nix store diff-closures /run/current-system ./result
sudo darwin-rebuild switch --flake ./nix
gcloud config virtualenv delete --quiet && gcloud config virtualenv create   # see below
git commit -am "nix: flake update" && git push
```

One input only: `nix flake update nixpkgs --flake ./nix`. Homebrew items don't update on switch
(`autoUpdate`/`upgrade` are off); run `brew upgrade` when you want them newer.

If an update breaks something, `sudo darwin-rebuild --rollback` and `git checkout nix/flake.lock`.

### Python virtualenvs after a Python update

Virtualenvs record their interpreter's path. uv-made ones point at `/etc/profiles/per-user/brian/bin`, so
patch releases (3.14.8 → 3.14.9) keep working. A new minor (3.14 → 3.15) needs `uv sync` in each project, or
`uv venv --allow-existing --python /etc/profiles/per-user/brian/bin/python3 .venv` to keep the installed
packages. gcloud's own virtualenv points at gcloud's exact Nix Python, so recreate it after every update:

```sh
gcloud config virtualenv delete --quiet && gcloud config virtualenv create
```

### Free disk space

Every switch keeps the previous generation for rollback, along with its packages.

```sh
darwin-rebuild --list-generations
sudo nix-collect-garbage --delete-older-than 30d     # drop generations older than 30 days, then their files
nix profile wipe-history --older-than 30d            # the same for `nix profile` (agent-browser)
brew cleanup                                         # Homebrew's download cache
```

### Set up a new Mac

1. Install Homebrew (<https://brew.sh>); nix-darwin manages it but doesn't install it.
2. Install Nix: `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`
3. Clone this repo to exactly `~/Projects/dotfiles`.
4. If the Mac's name differs (`scutil --get LocalHostName`), add a `darwinConfigurations."<name>"` entry in
   `flake.nix` next to `Brians-MacBook-Pro` (same modules), or rename the Mac.
5. Move aside the `/etc` files nix-darwin won't overwrite, then run the first switch:
   ```sh
   for f in zshrc zshenv zprofile bashrc; do sudo mv /etc/$f /etc/$f.before-nix-darwin; done
   sudo nix run 'github:nix-darwin/nix-darwin/ff0e21a#darwin-rebuild' -- switch --flake ~/Projects/dotfiles/nix
   ```
6. Make sure `~/.zprofile` doesn't run `brew shellenv` (it puts Homebrew in front of Nix).
7. Pinned agent-browser: `nix profile add ~/Projects/dotfiles/nix#agent-browser`.
8. Sign in again where needed: `gh auth login`, `gcloud auth login`, then `gcloud config virtualenv create`.
9. Herdr: install it, then `herdr-wallpaper` and `herdr-layout-look` (see `.config/herdr-app/README.md`).

To remove nix-darwin entirely: `sudo darwin-uninstaller`, then move the `.before-nix-darwin` files back.

## Troubleshooting

### "file not found" or "does not exist" during build

The file isn't tracked by git, so the flake can't see it. `git add` it (committing isn't needed) and build again.

### A switch registers a new generation, but the machine stays on the old one

Activation failed after the generation was recorded: `darwin-rebuild --list-generations` shows the new one,
but `readlink /run/current-system` still points at the old one. Read the end of the switch's output. Once it was
`brew cleanup` exiting 1 because Homebrew 7 refused a cask from an untrusted tap ("Refusing to load cask ...
from untrusted tap"). The fix was `trusted = true` on the tap in `darwin.nix`. To reproduce the Homebrew step
without sudo:

```sh
brew bundle --file="$(grep -o '/nix/store/[^ "]*Brewfile' /nix/var/nix/profiles/system/activate | head -1)" --no-upgrade --zap --force-cleanup
```

### brew's copy runs instead of Nix's

`which -a <tool>` shows both, and Homebrew's wins. Something put `/opt/homebrew/bin` in front of the Nix
profiles. Culprits found so far: `brew shellenv` in `~/.zprofile` (not in this repo) and prepends in
`.zshrc.mac`. Remove the prepend; nix-darwin already has Homebrew on PATH, after Nix. Check with a clean shell:
`env -i HOME=$HOME USER=$USER TERM=xterm zsh -lic 'echo $PATH'`.

### A command is "not found" right after a switch

The shell (or the app that started it) predates the switch and has the old PATH. `exec zsh`, or start a new
terminal. Claude Code sessions and tmux servers keep their old environment until restarted.

### brew uninstall removes more than asked

`brew uninstall` also removes dependencies nothing else needs, immediately. Uninstalling the gcloud-cli cask
took python@3.14 with it and broke three virtualenvs. Before uninstalling, look at
`brew deps --installed <pkg>`, and check which virtualenvs use a brew Python:

```sh
find ~ -maxdepth 5 -name pyvenv.cfg 2>/dev/null | xargs grep -l 'home = /opt/homebrew'
```

To keep a dependency, `brew install` it first (it then counts as requested) or set `HOMEBREW_NO_AUTOREMOVE=1`.

### sudo fails with "a terminal is required"

The command ran without a terminal (Claude Code's `!` prefix, an agent's shell). Run it in a terminal pane.

### A config edit didn't apply

Configs are linked straight to the repo, so the app may just need a reload (`tmux source ~/.tmux.conf`,
restart nvim). If the file is new, it needs a line in `links.nix` and a switch.

### rust-analyzer can't find the standard library

`RUST_SRC_PATH` comes from `home.nix` and is set by `~/.zshenv`. An editor started from the Dock doesn't read
zsh's files; start it from a terminal, or use a project devShell (the Rust template adds `rust-src` when
the project has no `rust-toolchain.toml`; otherwise list `rust-src` under `components` there).
