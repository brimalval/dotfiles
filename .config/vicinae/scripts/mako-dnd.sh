#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle Do Not Disturb
# @vicinae.mode silent
# @vicinae.icon 🔕
# @vicinae.keywords ["dnd", "notifications", "mako", "focus"]
# @vicinae.description Hide notification popups until toggled again; they still pile up in mako's history
# @vicinae.packageName Desktop
makoctl mode -t do-not-disturb >/dev/null
if makoctl mode | grep -qx do-not-disturb; then echo "Do Not Disturb on"; else echo "Do Not Disturb off"; fi
