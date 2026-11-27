#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Reload Waybar
# @vicinae.mode silent
# @vicinae.icon 📊
# @vicinae.keywords ["waybar", "bar", "reload"]
# @vicinae.description Re-read waybar's config and style
# @vicinae.packageName Desktop
pkill -SIGUSR2 -x waybar && echo 'Waybar reloaded' || echo 'Waybar is not running'
