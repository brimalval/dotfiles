# User-installed CLI tools, including uv and python shims.
case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Variables and PATH entries from home-manager (nix/home.nix: home.sessionVariables / sessionPath),
# for every shell, interactive or not. Node, Rust, Python and bun come from Nix: no version managers.
if [[ -r "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
  . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
fi

# Pinned agent-browser for herdr-browser, from nix/ (bump: docs/cli-version-management.md#bumping-the-pin).
if [[ -x "$HOME/.nix-profile/bin/agent-browser" ]]; then
  export HERDR_BROWSER_BIN="$HOME/.nix-profile/bin/agent-browser"
fi

# Default editor for non-interactive tools that need one.
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
