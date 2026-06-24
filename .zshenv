# User-installed CLI tools, including uv and python shims.
case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# FNM for non-interactive shells. Uses the default Node alias only.
export FNM_DIR="${FNM_DIR:-$HOME/.local/share/fnm}"

if [[ -d "$FNM_DIR/aliases/default/bin" ]]; then
  case ":$PATH:" in
    *:"$FNM_DIR/aliases/default/bin":*) ;;
    *) export PATH="$FNM_DIR/aliases/default/bin:$PATH" ;;
  esac
fi

case ":$PATH:" in
  *:"$FNM_DIR":*) ;;
  *) export PATH="$FNM_DIR:$PATH" ;;
esac

# Rust/cargo tools.
if [[ -r "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
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
