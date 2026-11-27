#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle Window Group
# @vicinae.mode silent
# @vicinae.icon 🗂️
# @vicinae.keywords ["group", "tabs", "stack"]
# @vicinae.description Turn the focused window into a tabbed group, or break the group up (SUPER+,)
# @vicinae.packageName Hyprland
hyprctl dispatch 'hl.dsp.group.toggle()' >/dev/null && echo 'Toggled group'
