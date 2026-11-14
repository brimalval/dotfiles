# Nix's profiles on PATH for every shell. nix-darwin does this on the Mac; on Linux the installer only
# hooks interactive shells (/etc/zsh/zshrc). Its run-once guard (__ETC_PROFILE_NIX_SOURCED) is inherited
# by child processes even when they rebuild PATH without Nix, so check PATH instead and clear the guard.
# Runs before the ~/.local/bin prepend below, so ~/.local/bin stays first (nix/README.md: PATH order).
if [[ "$OSTYPE" == linux* && -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
      && ":$PATH:" != *":/nix/var/nix/profiles/default/bin:"* ]]; then
  unset __ETC_PROFILE_NIX_SOURCED
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# User-installed CLI tools, installers' links (claude, codex, herdr).
case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Variables and PATH entries from home-manager (nix/home.nix: home.sessionVariables / sessionPath),
# for every shell, interactive or not. Node, Rust, Python and bun come from Nix: no version managers.
# Mac (home-manager inside nix-darwin): /etc/profiles/per-user. WSL (standalone home-manager): ~/.nix-profile.
for __hm_vars in \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"; do
  if [[ -r "$__hm_vars" ]]; then
    . "$__hm_vars"
    break
  fi
done
unset __hm_vars

# Pinned agent-browser for herdr-browser, from nix/ (bump: docs/cli-version-management.md#bumping-the-pin).
if [[ -x "$HOME/.nix-profile/bin/agent-browser" ]]; then
  export HERDR_BROWSER_BIN="$HOME/.nix-profile/bin/agent-browser"
fi

# Default editor for non-interactive tools that need one.
# Fallbacks for machines without nix-darwin; on the Mac, nix/darwin.nix sets both.
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"

# XDG base dirs are safe, widely respected, and quiet.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Add Go to PATH.
if [[ -r "/usr/local/go/bin" ]]; then
  export PATH=$PATH:/usr/local/go/bin
  export PATH=$PATH:$HOME/go/bin
fi
