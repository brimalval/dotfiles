#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Close Window
# @vicinae.mode silent
# @vicinae.icon ✖️
# @vicinae.keywords ["close", "kill", "quit", "window"]
# @vicinae.description Close the focused window (SUPER+SHIFT+Q)
# @vicinae.packageName Hyprland
hyprctl dispatch 'hl.dsp.window.close()' >/dev/null && echo 'Closed window'
