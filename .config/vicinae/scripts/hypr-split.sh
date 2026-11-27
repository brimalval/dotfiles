#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle Split Direction
# @vicinae.mode silent
# @vicinae.icon ↔️
# @vicinae.keywords ["split", "layout", "dwindle"]
# @vicinae.description Flip the focused split between horizontal and vertical (SUPER+/)
# @vicinae.packageName Hyprland
hyprctl dispatch 'hl.dsp.layout("togglesplit")' >/dev/null && echo 'Flipped split'
