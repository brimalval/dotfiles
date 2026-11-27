#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Move Window to Workspace
# @vicinae.mode silent
# @vicinae.icon 📦
# @vicinae.keywords ["move", "send", "workspace", "window"]
# @vicinae.description Send the focused window to workspace 1-9 or a letter, as SUPER+SHIFT+<key> does
# @vicinae.packageName Hyprland
# @vicinae.argument1 { "type": "text", "placeholder": "1-9 or letter" }

# Letter workspaces are ids 11-30 in this order; keep in sync with .config/hypr/hyprland.lua.
letters=ABCDEGIMNOPRSTUVWXYZ
key=$(printf '%s' "$1" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')

if [[ $key =~ ^[1-9]$ ]]; then
  id=$key
elif [[ ${#key} -eq 1 && $letters == *"$key"* ]]; then
  prefix=${letters%%"$key"*}
  id=$((11 + ${#prefix}))
else
  echo "No workspace '$1' (use 1-9 or one of $letters)"
  exit 1
fi

hyprctl dispatch "hl.dsp.window.move({ workspace = $id, follow = false })" >/dev/null && echo "Moved to workspace $key"
