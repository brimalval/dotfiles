# CLI version management for these dotfiles

Research as of 2026-11-06. Machine: macOS on Apple Silicon. Today CLI tools come from Homebrew and Node comes from fnm.
The trigger is Herdr's `herdr-browser`, which needs **exactly** agent-browser `0.41.1`. Homebrew ships `0.41.2`, so the browser refuses to start.

Legend used throughout:
- **[verified]**: checked in a primary source or on this machine today.
- **[inferred]**: my reading or reasoning, not tested.

Every config below is an **untested proposal**. Nothing was installed and no shell config was changed.

---

## Recommendation

Use **Nix**, starting small:
1. Pin this one tool with a flake that lives in this repo.
2. Grow into home-manager later.

Keep **mise** as the low-effort fallback if Nix turns out to be more than you want.

Why Nix is practical for this one tool:
- **agent-browser ships a prebuilt macOS binary on every GitHub release.** [verified]
  - It is the same file the npm package carries, byte for byte: `cmp` of `agent-browser-darwin-arm64` from the v0.41.1 release and from the npm tarball matched.
  - So a Nix package for any version is about 15 lines and builds instantly: fetch one file, check its hash, copy it.
- **nixpkgs already has 0.41.1 too, and the cache has it built for Apple Silicon.** [verified]
  - Hydra build 352232255 succeeded, and its `cache.nixos.org` narinfo returns HTTP 200.
  - But nixpkgs lags releases, and the Herdr pin moves, so your own small package is the dependable route.

Steps:

1. **Install Nix with the Determinate installer.** It has flakes on, survives macOS upgrades, and has a one-command uninstall. See [Nix: which installer](#which-installer).
2. **Add `nix/` to this repo** with the [starter flake below](#starter-nix-flake-untested): `flake.nix` plus `pkgs/agent-browser.nix`.
   - Add `^/nix` (and `^/docs`) to `.stow-local-ignore` so stow does not link them into `~`.
3. **Install it into your profile:** `nix profile add ~/Projects/dotfiles/nix#agent-browser`.
   - It lands at `~/.nix-profile/bin/agent-browser`.
4. **Point herdr-browser at it.**
   - Run `brew uninstall agent-browser`. Homebrew's copy wins every PATH race; see [Why PATH alone loses](#pointing-herdr-browser-at-the-pinned-binary).
   - Set `export HERDR_BROWSER_BIN="$HOME/.nix-profile/bin/agent-browser"` in `.zshenv`.
5. **Chrome:** already present in `~/.agent-browser/browsers/chrome-155.0.8059.39`, which lives outside Nix. The pinned binary should reuse it. If not, run `agent-browser install` once.
6. **When Herdr bumps the pin:** change `version`, refresh `hash`, then `nix profile upgrade agent-browser`. See [Bumping the pin](#bumping-the-pin).
7. **Later:** move the profile to home-manager, then Node, following the [learning path](#learning-path-for-nix).

Leave **fnm alone for now**. Moving Node is step three of the learning path, not a prerequisite.

**If you would rather not touch Nix yet**, mise does the same job in two lines. The mise registry maps `agent-browser` to aqua's GitHub-release backend, so it fetches the same native binary and needs no Node. See [the mise starter](#starter-mise-config-untested).

---

## Comparison

| | **Nix** (flake + `nix profile` / home-manager) | **mise** | **aqua** | **proto** | **asdf** |
|---|---|---|---|---|---|
| Pin agent-browser 0.41.1 | Own 15-line package (any version, same day). Or nixpkgs-unstable, where 0.41.1 is cached. | `agent-browser = "0.41.1"` (aqua backend), or `"npm:agent-browser"` | `vercel-labs/agent-browser@v0.41.1` (in the standard registry) | `"npm:agent-browser" = "0.41.1"` (native npm backend since 0.57) | No plugin; manual `npm i -g` under asdf-nodejs |
| Lag when Herdr's pin moves | None with own package; nixpkgs took ~1–3 days for 0.41.1 | None | None | None | n/a |
| Needs Node for this tool | No | No (aqua backend); the npm backend needs Node at run time | No | Probably (unconfirmed) | Yes |
| How it reaches PATH | `~/.nix-profile/bin` symlinks to immutable store paths | Shims or `activate` | aqua-proxy symlinks | Shims or `activate` | Shims |
| Replace fnm | Yes, per-project via flakes/devShells; global via profile | Yes; reads `.nvmrc`/`.node-version` once enabled | Weak | Yes | Yes |
| Reproducible lock | `flake.lock` (exact nixpkgs commit), and every file hashed | `mise.lock` (versions, URLs, checksums) | Checksums opt-in | Lockfile | No |
| Install footprint | `/nix` APFS volume, daemon, build users | One binary + `~/.local/share/mise` | One binary | One binary + `~/.proto` | One binary + `~/.asdf` |
| Undo | `/nix/nix-installer uninstall` (Determinate) | `mise implode` | Delete dir | Delete dir | Delete dir |
| Learning curve | Steep, but transfers to whole-system config | Gentle | Gentle | Gentle | Gentle |
| Fits "learn Nix" goal | **Yes** | No | No | No | No |

---

## Pointing herdr-browser at the pinned binary

This section is verified on this machine unless marked otherwise.

**How herdr-browser chooses a binary.** `~/.local/bin/herdr-browser` is a `#!/bin/sh` script with `PIN=0.41.1`.
- It takes `bin=${HERDR_BROWSER_BIN:-$(command -v agent-browser)}`.
- It runs `readlink -f` on that path.
- It caches the version under `~/.herdr/browser/.version`, keyed on the resolved real path and its mtime.
- It refuses to run unless the version equals `PIN`.

**Why PATH alone loses.** In a clean login shell, Homebrew comes first:
- Test: `env -i HOME=$HOME zsh -lc 'echo $PATH'`.
- `/etc/zprofile` runs `path_helper`, and `/etc/paths.d/homebrew` makes it place `/opt/homebrew/bin` first.
- Everything this repo's `.zshenv` adds (`~/.local/bin`, fnm) is pushed after the system paths.
- Interactive shells also prepend `/opt/homebrew/bin` again in `.zshrc.mac`.
- So while Homebrew's agent-browser is installed, `command -v agent-browser` finds 0.41.2.

That gives three options, in order of preference:

1. **`brew uninstall agent-browser`, plus `HERDR_BROWSER_BIN` pointing at a stable symlink.**
   ```sh
   # .zshenv: read by every zsh, interactive or not. path_helper only rewrites PATH, so this survives.
   export HERDR_BROWSER_BIN="$HOME/.nix-profile/bin/agent-browser"
   ```
   - `~/.nix-profile/bin/agent-browser` keeps the same path, but its target moves to a new `/nix/store/...-agent-browser-X` on every bump.
   - herdr-browser's `readlink -f` then sees a new path and re-checks the version. That is exactly right. [verified from the script; Nix symlink behaviour inferred]
   - [inferred] Whether Herdr passes non-PATH variables through depends on how it starts processes. Its terminals run zsh, which always reads `.zshenv`, so commands started from those terminals should see the variable. Uninstalling Homebrew's copy makes the fallback `command -v` path safe anyway.
2. **Put the pinned bin dir first in `~/.zprofile`.** That file runs after `/etc/zprofile` and `path_helper`:
   ```sh
   # ~/.zprofile: after path_helper, so it wins in login shells
   export PATH="$HOME/.nix-profile/bin:$PATH"
   ```
   This repo has no `.zprofile` yet, so it would be a new stowed file. `.zshrc.mac` would still re-prepend Homebrew in interactive shells, so this also needs the brew uninstall to be airtight.
3. **Keep both and rely only on `HERDR_BROWSER_BIN`.** This works, but anything else that calls `agent-browser` directly gets 0.41.2.

**mise gotcha: don't point `HERDR_BROWSER_BIN` at a mise shim.** [verified from script + mise docs]
- mise shims are symlinks to the `mise` binary itself, so `readlink -f` resolves to `mise`.
- herdr-browser's version cache is keyed on that path and its mtime. After a pin bump the cache keeps saying the old version until mise itself updates.
- Use the real install path instead: `export HERDR_BROWSER_BIN="$(mise which agent-browser)"`.
- The mise shims docs also warn that `command -v` succeeds on a shim even when the tool isn't installed.

---

## Bumping the pin

When Herdr moves (watch `PIN=` in `~/.local/bin/herdr-browser`):

- **Nix (own package):**
  1. Edit `version` in `nix/pkgs/agent-browser.nix`.
  2. Get the new hash with `nix store prefetch-file --json https://github.com/vercel-labs/agent-browser/releases/download/v<NEW>/agent-browser-darwin-arm64`, and copy `hash`.
     - Or set `hash = lib.fakeHash;`, build, and copy the "got:" hash from the error.
  3. Run `nix profile upgrade agent-browser` (or `home-manager switch`), then commit.
  4. Roll back with `nix profile rollback`.
- **Nix (nixpkgs route):** `nix flake update nixpkgs` once nixpkgs has the version. Check with `nix eval ~/Projects/dotfiles/nix#agent-browser.version`.
  - nixhub.io is behind: on 2026-11-06 it listed 0.38.2 as newest, while nixpkgs-unstable already had 0.41.1. [verified]
- **mise:** edit the version in `config.toml` (or `mise use -g agent-browser@<NEW>`), then `mise install`.
- **Every route:** run `agent-browser install` only if the new version wants a newer Chrome.

---

## Starter: Nix flake (untested)

**Untested proposal.** It's written against current docs, but nothing has been built. The hash is real: it's the sha256 of the v0.41.1 `agent-browser-darwin-arm64` release asset, computed today.

```
nix/
  flake.nix
  flake.lock          # generated by the first `nix build` / `nix profile add`; commit it
  home.nix            # only once you move to home-manager
  pkgs/agent-browser.nix
```

`nix/pkgs/agent-browser.nix`:

```nix
# Pins agent-browser to the exact version Herdr wants, from the prebuilt GitHub release binary.
{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agent-browser";
  version = "0.41.1"; # keep equal to PIN= in ~/.local/bin/herdr-browser

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${finalAttrs.version}/agent-browser-darwin-arm64";
    hash = "sha256-Y7Cpe4WlS0ybKHExivdBBMKbgKvVB7U6MDFohOBihUs=";
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/agent-browser
    runHook postInstall
  '';

  meta = {
    description = "Browser automation CLI for AI agents (pinned for Herdr)";
    homepage = "https://agent-browser.dev";
    license = lib.licenses.asl20; # package.json: Apache-2.0
    platforms = [ "aarch64-darwin" ];
    mainProgram = "agent-browser";
  };
})
```

`nix/flake.nix`:

```nix
{
  description = "Brian's dotfiles: pinned CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Stage 2 (home-manager): uncomment
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        agent-browser = pkgs.callPackage ./pkgs/agent-browser.nix { };
        # Alternative: nixpkgs' own build (from source, cached), when its version matches Herdr's pin:
        agent-browser-nixpkgs = pkgs.agent-browser;
        default = self.packages.${system}.agent-browser;
      };

      # Stage 2: standalone home-manager, `home-manager switch --flake ~/Projects/dotfiles/nix#brian`
      # homeConfigurations.brian = inputs.home-manager.lib.homeManagerConfiguration {
      #   inherit pkgs;
      #   extraSpecialArgs = { myPkgs = self.packages.${system}; };
      #   modules = [ ./home.nix ];
      # };
    };
}
```

Stage 1, using `nix profile`:

```sh
nix build ~/Projects/dotfiles/nix#agent-browser && ./result/bin/agent-browser --version   # expect: agent-browser 0.41.1
nix profile add ~/Projects/dotfiles/nix#agent-browser   # `nix profile install` is an alias
nix profile list
```

Stage 2, `nix/home.nix` (home-manager standalone, only packages, no dotfiles):

```nix
{ pkgs, myPkgs, ... }: {
  home.username = "brian";
  home.homeDirectory = "/Users/brian";
  home.stateVersion = "26.05";   # set once at first switch, then never change
  programs.home-manager.enable = true;

  home.packages = [ myPkgs.agent-browser ];

  # Leave zsh to stow: don't enable programs.zsh. home-manager refuses to replace an
  # existing symlink it doesn't manage (stow's), so keep the two tools on separate files.
}
```

When you switch to home-manager:
- Run `nix profile remove agent-browser` first, so the profile and home-manager don't both own it.
- The binary stays at `~/.nix-profile/bin/agent-browser`, so `HERDR_BROWSER_BIN` doesn't change. [inferred from the HM standalone docs, which use `~/.nix-profile`]

Even quicker, with no package file: pin nixpkgs' own build while it matches Herdr's pin. The commit below is nixpkgs-unstable on 2026-11-04, which has 0.41.1. [verified]

```sh
nix profile add github:NixOS/nixpkgs/6dadaf4375be35033e1c84395adbd53ff5fded96#agent-browser
```

This is the fastest way to try Nix. It stops working the first time Herdr pins a version nixpkgs doesn't have yet. On 2026-11-06, 0.41.2 was not in nixpkgs.

## Starter: mise config (untested)

**Untested proposal.** The file would be `~/.config/mise/config.toml`, symlinked from this repo's `.config/mise/config.toml` by stow.

```toml
[tools]
# Registry short name -> aqua backend -> GitHub release binary. No Node needed.
agent-browser = "0.41.1"   # keep equal to PIN= in ~/.local/bin/herdr-browser

# Alternative: the npm package (needs node on PATH at run time; engines: node >= 24)
# "npm:agent-browser" = "0.41.1"

# Later, to replace fnm:
# node = "24"

[settings]
# Only if/when replacing fnm: honour .nvmrc / .node-version (off by default)
# idiomatic_version_file_enable_tools = ["node"]
```

Shell wiring, as the mise docs recommend for login and non-interactive shells:

```sh
# ~/.zprofile (new file in this repo)
eval "$(mise activate zsh --shims)"
# ~/.zshrc (interactive): replace with full activation if you want hooks/env
# eval "$(mise activate zsh)"
# .zshenv, for herdr-browser: real path, not the shim (see the gotcha above)
# export HERDR_BROWSER_BIN="$(mise which agent-browser 2>/dev/null)"  # costs one mise call per shell; or hard-code the path it prints
```

---

## mise

[verified] unless marked otherwise.

- **Version:** latest is [v2026.11.2](https://github.com/jdx/mise/releases) (2026-11-05).
- **Global config:**
  - `~/.config/mise/config.toml`, plus `conf.d/` and `config.local.toml`. `mise use -g` writes there.
  - `MISE_GLOBAL_CONFIG_FILE` (env only) points mise at a single file.
  - The docs show symlinking config from a dotfiles repo. ([configuration](https://mise.jdx.dev/configuration.html#global-config), [settings](https://mise.jdx.dev/configuration/settings.html#global_config_file))
- **agent-browser via the registry:**
  - [`registry/agent-browser.toml`](https://github.com/jdx/mise/blob/main/registry/agent-browser.toml) says `backends = ["aqua:vercel-labs/agent-browser"]`.
  - That aqua entry downloads the raw `agent-browser-{{.OS}}-{{.Arch}}` release asset ([aqua-registry](https://github.com/aquaproj/aqua-registry/blob/main/pkgs/vercel-labs/agent-browser/registry.yaml)).
  - That entry declares no checksum, cosign or SLSA settings, so you get no signature verification beyond a `mise.lock` checksum.
- **npm backend:** `"npm:agent-browser" = "0.41.1"` ([docs](https://mise.jdx.dev/dev-tools/backends/npm.html)).
  - Installing uses mise's embedded `aube` package manager, so no Node is needed to install. *Running* needs Node in `[tools]` or on PATH.
  - Dependency lifecycle scripts are off by default (`allow_builds` opts in).
  - [verified locally] agent-browser's own postinstall only sets the binary executable and repoints npm's global bin link. If it is skipped, the package's `bin/agent-browser.js` launcher still finds the bundled `agent-browser-darwin-arm64`, chmods it and spawns it, as long as Node is present.
  - Sigstore provenance is checked by default for the top-level package.
  - `minimum_release_age` (default 24h) skips exact pins.
- **Replacing fnm** ([node docs](https://mise.jdx.dev/lang/node.html)):
  - `mise use -g node@24`.
  - `.nvmrc`/`.node-version` are ignored until `mise settings add idiomatic_version_file_enable_tools node`.
  - There is no fnm-specific migration guide.
  - [inferred] This repo would drop the fnm blocks in `.zshenv` and `.zshrc.common`.
- **Shims vs activate** ([shims docs](https://mise.jdx.dev/dev-tools/shims.html)):
  - The docs recommend shims for IDEs, GUI apps and login profiles: `eval "$(mise activate zsh --shims)"` in `~/.zprofile`, full `mise activate zsh` in `~/.zshrc`.
  - `activate` sets PATH when it runs, then refreshes it at each prompt and on `cd`. `.zshrc` isn't read by non-interactive login shells, hence shims in `.zprofile`.
  - Shim caveats:
    - no `[env]` vars or hooks
    - `which` shows the shim
    - `command -v` succeeds even if the tool isn't installed
    - a small per-call cost
  - For herdr-core's terminals (login-shell PATH), shims in `.zprofile` are the documented fit. Mind the herdr-browser shim gotcha above.
- **Bump and lock:**
  - `mise upgrade --bump` rewrites exact pins ([docs](https://mise.jdx.dev/cli/upgrade.html)).
  - `mise which` prints the real binary.
  - `mise.lock` records versions, URLs and checksums. Global tools are locked with `mise lock --global`; symlink `~/.config/mise/mise.lock` into the repo ([docs](https://mise.jdx.dev/dev-tools/mise-lock.html)).
- **Undo:** `mise implode` removes binary, installs, state and cache, and `--config` removes config too ([docs](https://mise.jdx.dev/cli/implode.html)). Remove the activate lines by hand.

**Verdict:** the fastest fix, and a good fnm replacement. It teaches nothing about Nix.

## Nix on macOS

### Which installer

- **Determinate Nix Installer** ([README](https://github.com/DeterminateSystems/nix-installer)): v3.24.2 (2026-11-05), installing Determinate Nix v3.24.2 ([releases](https://github.com/DeterminateSystems/nix-src/releases)). [verified]
  - `nix-command` and `flakes` are on by default.
  - It writes a receipt to `/nix/receipt.json`, and `/nix/nix-installer uninstall` reverses everything, including the APFS volume and launchd daemons.
  - It is designed to survive macOS upgrades. Its Sequoia `_nixbld` UID clash has a built-in fix: `/nix/nix-installer repair sequoia --move-existing-users`.
  - `--prefer-upstream-nix` still exists but is "not a supported configuration… we may remove it". The planned January 2026 removal ([blog](https://determinate.systems/blog/installer-dropping-upstream/)) has not happened. [verified in README]
- **Upstream installer** ([nixos.org/download](https://nixos.org/download/)): Nix 2.35.4, multi-user, needs macOS 14 or newer. [verified]
  - Flakes are off unless you add `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`.
  - Uninstalling is [7 manual steps](https://nix.dev/manual/nix/2.35/installation/uninstall): restore `/etc/zshrc` backups, unload two launchd daemons, delete build users and group, edit fstab with `vifs`, edit `/etc/synthetic.conf`, remove `/etc/nix`, then `diskutil apfs deleteVolume /nix`.
- **NixOS/experimental-nix-installer** ([repo](https://github.com/NixOS/experimental-nix-installer)): a community fork of Determinate's installer, labelled beta, with flakes off unless you pass `--enable-flakes`. [verified]

**Pick Determinate** for the clean uninstall and flakes by default. [inferred] Determinate Nix is a downstream of upstream Nix. Everything in this doc works the same on either.

### Cost to undo, and coexisting with Homebrew

- **Undo:** `/nix/nix-installer uninstall`, then delete `nix/` from this repo and the `HERDR_BROWSER_BIN` line.
  - The `/nix` volume is a separate APFS volume, so removing it leaves no residue in your home folder except `~/.nix-profile`, `~/.local/state/nix` and `~/.cache/nix`.
  - With nix-darwin, run `sudo darwin-uninstaller` first; the installer README warns of broken networking otherwise. [verified]
- **Homebrew:** Nix never touches `/opt/homebrew`.
  - The only overlap is PATH order, and for this tool the plan sidesteps it with `HERDR_BROWSER_BIN` plus uninstalling the brew formula.
  - [inferred] The installers hook Nix's PATH into `/etc/zshrc` (interactive). Where Nix lands relative to `/opt/homebrew/bin` here depends on this repo's `.zshrc.mac`, which prepends Homebrew. Check with `echo $PATH` after installing.
  - nix-darwin later offers a [`homebrew` module](https://nix-darwin.github.io/nix-darwin/manual/index.html) to declare casks and brews. It does not install Homebrew itself.

### Ways in, gentlest first

1. **`nix profile`:** imperative, like `brew install`, but every change is a rollback-able generation.
   - [`nix profile add`](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-profile-add) (`install` is now an alias).
   - [`upgrade`](https://nix.dev/manual/nix/2.35/command-ref/new-cli/nix3-profile-upgrade) won't move a *locked* ref such as a nixpkgs commit hash. That is useful for pins.
   - `rollback`.
2. **home-manager standalone** ([manual](https://nix-community.github.io/home-manager/nix-flakes/standalone.html)): declarative user packages. The current release is `release-26.05`.
   - `home-manager switch --flake <path>#brian`.
   - Without `programs.zsh` you source `~/.nix-profile/etc/profile.d/hm-session-vars.sh` yourself, only if you use `home.sessionVariables`.
   - **Stow conflict:** home-manager won't overwrite an unmanaged *symlink*, and stow's links are exactly that. `-b backup` only handles regular files ([dotfiles chapter](https://nix-community.github.io/home-manager/usage/dotfiles.html)). Keep home-manager on packages until you deliberately move a file from stow to home-manager.
3. **nix-darwin** ([README](https://github.com/nix-darwin/nix-darwin)): system level, covering `/etc`, launchd, macOS defaults and the Homebrew module.
   - `nix flake init -t nix-darwin/nix-darwin-26.05`, then `sudo darwin-rebuild switch` (sudo is now required).
   - With Determinate, set `nix.enable = false;` or use Determinate's module ([guide](https://docs.determinate.systems/guides/nix-darwin/)).
   - Worth it only once home-manager feels comfortable.
- **devbox** ([pinning](https://www.jetify.com/docs/devbox/guides/pinning-packages)): `devbox global add agent-browser@0.41.1` resolves through Nixhub. **This fails today** because Nixhub stops at 0.38.2. It also installs Nix for you, and hides Nix. [verified]
- **flox** ([install](https://flox.dev/docs/man/flox-install/)): `flox install agent-browser@0.41.1` from a daily nixos-unstable catalog. Its macOS `.pkg` brings its own Nix and "will reconfigure an existing Nix installation" ([docs](https://flox.dev/docs/install-flox/install/)). [verified] Nice UX, but it also hides the Nix you want to learn.

### Pinning agent-browser exactly

- **nixpkgs has it at 0.41.1:**
  - nixpkgs-unstable at `6dadaf4375be35033e1c84395adbd53ff5fded96` (2026-11-04). The bump was commit [`b1240ec`](https://github.com/NixOS/nixpkgs/commits/master/pkgs/by-name/ag/agent-browser/package.nix) on 2026-11-02.
  - `nixos-26.05` has only 0.27.0.
  - It is built **from source**: `rustPlatform.buildRustPackage` plus a pnpm-built dashboard ([package.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ag/agent-browser/package.nix)).
  - Hydra built `agent-browser-0.41.1` for aarch64-darwin on 2026-11-06, and the output is on `cache.nixos.org`, so no local compile is needed. [verified]
- **nixhub.io lags:** it lists 0.38.2, 0.38.1, 0.27.0, 0.25.4 and 0.23.3 only ([nixhub](https://www.nixhub.io/packages/agent-browser)). Use the nixpkgs git history instead. [verified]
- **Override vs own package.**
  - Overriding nixpkgs' source build to a version it doesn't have means updating three hashes: source, `cargoHash` and the pnpm deps.
  - Repackaging the prebuilt release binary means one hash. Hence the starter's own package.
  - Fetching the npm tarball would also work, and `npm view agent-browser@X dist.integrity` hands you an SRI hash directly. But it is 54 MB of every platform's binary versus 16 MB. [verified sizes]
- **Missing skills data:** the prebuilt binary alone lacks the npm package's `skill-data/` folder. The binary says "Skills directory not found. Set AGENT_BROWSER_SKILLS_DIR or reinstall via npm." [verified in strings]
  - [inferred] Only the `skills` subcommand needs it, and herdr-browser doesn't use it.
- **Chrome under Nix:**
  - The nixpkgs package does not wrap a browser. agent-browser still downloads Chrome for Testing at run time with `agent-browser install`, into `~/.agent-browser/browsers/`, outside the store. On this machine that holds `chrome-155.0.8059.39`. [verified]
  - Chromium in nixpkgs is `platforms = lib.platforms.linux` ([browser.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/chromium/browser.nix)), so Chrome itself can't come from Nix on macOS. [verified]
  - To point at a fixed browser, use `AGENT_BROWSER_EXECUTABLE_PATH` or `--executable-path`, both in agent-browser's README. [verified]

## asdf

asdf is now [v0.20.2](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md), rewritten in Go at 0.16. It is shim-based with a global `~/.tool-versions`, and asdf-nodejs would replace fnm fine.
- There is **no agent-browser plugin and no generic npm plugin** in the [official index](https://github.com/asdf-vm/asdf-plugins/tree/master/plugins). You'd fall back to `npm i -g agent-browser@0.41.1` under an asdf-managed Node, which is the unpinned state you're trying to escape.
- mise does everything asdf does, with the same `.tool-versions` file, and has the aqua/npm backends on top.
- **Not recommended.** [verified facts; verdict mine]

## aqua

aqua ([v2.66.1](https://github.com/aquaproj/aqua/releases)) installs GitHub-release binaries declared in `aqua.yaml`, with lazy-install proxy symlinks and a strong supply-chain story (checksums, Cosign, SLSA, attestations).
- agent-browser is in its [standard registry](https://github.com/aquaproj/aqua-registry/blob/main/pkgs/vercel-labs/agent-browser/registry.yaml), so `vercel-labs/agent-browser@v0.41.1` pins exactly what's needed.
- That entry declares no signatures, so the security features don't apply to it.
- There is no npm package type, Node switching is weak, and the global config needs `AQUA_GLOBAL_CONFIG`.
- **Not recommended standalone.** mise already uses aqua's registry for this exact tool, and adds Node management. [verified facts; verdict mine]

## proto

proto ([v0.63.2](https://github.com/moonrepo/proto/releases), moonrepo) is shim-based with a TOML `~/.proto/.prototools`. Node, npm, pnpm and yarn are first-class plugins, and it has had a native `npm:` backend since v0.57.0 ([changelog](https://github.com/moonrepo/proto/blob/master/CHANGELOG.md)), so `"npm:agent-browser" = "0.41.1"` should work.
- Unconfirmed: whether that backend needs a proto-managed Node, and whether agent-browser specifically behaves.
- It's a credible mise alternative, especially in moon monorepos, but has a smaller ecosystem.
- **Not recommended** over mise here. [verified facts; verdict mine]

---

## Learning path for Nix

Each step is useful on its own, so you can stop after any of them.

1. **One pinned tool (this doc).**
   - Install Determinate Nix, add `nix/` with the agent-browser package, then `nix build` and `nix profile add`.
   - You learn: flakes, `flake.lock`, derivations (`mkDerivation`, `fetchurl`, hashes), the store, profiles and rollback.
   - Try `nix profile history` and `nix profile rollback` after a bump.
2. **Throwaway shells, no install.**
   - `nix shell nixpkgs#jq nixpkgs#ripgrep`, and `nix run nixpkgs#cowsay -- hi`.
   - Then add a `devShells.default` to a real project with its Node version: `nix develop`, or `use flake` with direnv.
   - This is where Nix starts replacing fnm per project.
3. **home-manager for user packages.**
   - Move the profile into `homeConfigurations.brian` (stage 2 above), then migrate a few Homebrew CLI formulae (ripgrep, fd, jq, Node) into `home.packages`.
   - Leave dotfiles to stow. Later, move one config file at a time from stow to home-manager (`programs.git`, say) once you see the value.
   - At this point fnm can go: Node comes from `home.packages` globally and from `devShells` per project.
4. **nix-darwin.** Once home-manager is boring: macOS defaults, launchd agents, and the `homebrew` module to declare the casks Nix can't replace. home-manager becomes a nix-darwin module.

Resources (current as of 2026-11):
- [nix.dev tutorials](https://nix.dev/tutorials/): official step-by-step basics; start with "First steps" and "Packaging existing software".
- [Zero to Nix](https://zero-to-nix.com): short, flakes-first quick start from Determinate Systems, matching the installer recommended here.
- [NixOS & Flakes Book (ryan4yin)](https://nixos-and-flakes.thiscute.world): the clearest explanation of flakes and home-manager. Examples lean NixOS, but the concepts carry straight over.
- [Home Manager manual](https://nix-community.github.io/home-manager/): read "Standalone with flakes" and "Dotfiles" (for the stow coexistence rules).
- [nix-darwin README and manual](https://github.com/nix-darwin/nix-darwin): for step 4.

---

## What was verified vs inferred

**Verified today** (docs, registries, or this machine):
- Versions and dates:
  - mise v2026.11.2
  - Determinate Nix and installer v3.24.2
  - Nix 2.35.4
  - home-manager release-26.05
  - asdf v0.20.2, aqua v2.66.1, proto v0.63.2
  - agent-browser 0.41.1 published 2026-11-01, 0.41.2 on 2026-11-03
- agent-browser packaging:
  - The npm tarball carries prebuilt binaries for every platform; its `engines` field is `node >= 24`.
  - The GitHub release `agent-browser-darwin-arm64` is identical to the npm-bundled one, and its sha256 SRI is `sha256-Y7Cpe4WlS0ybKHExivdBBMKbgKvVB7U6MDFohOBihUs=`.
- nixpkgs:
  - nixpkgs-unstable has agent-browser 0.41.1, built from source, with the Hydra aarch64-darwin build cached.
  - nixhub stops at 0.38.2.
  - Chromium in nixpkgs is Linux-only.
- Registries: mise's registry uses aqua for agent-browser, and the aqua entry is the raw release binary with no signature config.
- This machine:
  - In a clean login shell, `path_helper` puts `/opt/homebrew/bin` ahead of everything `.zshenv` adds, so Homebrew's 0.41.2 wins.
  - herdr-browser's binary selection and version cache logic is as described.
  - Chrome is stored in `~/.agent-browser/browsers/`.
- The installer facts, uninstall steps, stow/home-manager symlink conflict, and devbox/flox behaviour, each as cited.

**Inferred, not tested:**
- That the starter flake, package and mise config work as written.
- That `HERDR_BROWSER_BIN` from `.zshenv` reaches herdr-browser in every way Herdr starts it.
- That the pinned binary reuses the existing Chrome without re-running `agent-browser install`.
- That only `agent-browser skills` needs `skill-data/`.
- Where Nix's PATH entries land relative to Homebrew after install.
- That home-manager standalone keeps `~/.nix-profile/bin` as the binary path.
- proto's npm backend behaviour with agent-browser.
