#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Reload Hyprland Config
# @vicinae.mode silent
# @vicinae.icon 🔄
# @vicinae.keywords ["reload", "hyprland", "config"]
# @vicinae.description Re-read hyprland.lua
# @vicinae.packageName Hyprland
hyprctl reload >/dev/null && echo 'Hyprland config reloaded'
