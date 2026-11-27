#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle Fullscreen
# @vicinae.mode silent
# @vicinae.icon ⛶
# @vicinae.keywords ["fullscreen", "maximize", "window"]
# @vicinae.description Fullscreen the focused window, or leave fullscreen
# @vicinae.packageName Hyprland
hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })' >/dev/null && echo 'Toggled fullscreen'
