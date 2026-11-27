#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle Floating
# @vicinae.mode silent
# @vicinae.icon 🪟
# @vicinae.keywords ["float", "tile", "window"]
# @vicinae.description Float or tile the focused window
# @vicinae.packageName Hyprland
hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })' >/dev/null && echo 'Toggled floating'
