#! /usr/bin/env zsh

(( ${+__zshrc_self} )) || typeset -r __zshrc_self="${(%):-%N}"
(( ${+__zshrc_dir} )) || typeset -r __zshrc_dir="${__zshrc_self:A:h}"

PLATFORM="unknown"

if [[ -n "$WSL_DISTRO_NAME" || -n "$WSL_INTEROP" ]]; then
  PLATFORM="wsl"
else
  if [[ -r /proc/version ]]; then
    typeset __proc_version
    __proc_version=$(< /proc/version)
    if [[ "$__proc_version" == *Microsoft* || "$__proc_version" == *microsoft* || "$__proc_version" == *WSL* || "$__proc_version" == *wsl* ]]; then
      PLATFORM="wsl"
    fi
  fi

  if [[ "$PLATFORM" == "unknown" ]]; then
    if command -v uname >/dev/null 2>&1; then
      typeset __uname
      __uname="$(uname -s 2>/dev/null)"
      if [[ "$__uname" == "Darwin" ]]; then
        PLATFORM="mac"
      fi
    fi
    if [[ "$PLATFORM" == "unknown" && "${OSTYPE:-}" == darwin* ]]; then
      PLATFORM="mac"
    fi
  fi
fi

export PLATFORM

if [[ "$PLATFORM" == "unknown" ]]; then
  print -u2 "warning: platform detection defaulted to unknown"
fi

source_fragment() {
  local fragment="$1"

  if [[ -r "$fragment" ]]; then
    source "$fragment"
  else
    print -u2 "warning: could not load ${fragment:t} (expected at $fragment)"
  fi
}

source_fragment "${__zshrc_dir}/.zshrc.common"
source_fragment "${__zshrc_dir}/.zshrc.${PLATFORM}"
