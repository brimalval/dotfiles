Local Shepherdr patches (made against Shepherdr 3.0.0 on herdr-app 0.1.13, macOS, 2026-11-04..05).
Unified diffs, -p1 relative to ~/.config/herdr-app/mods. Apply in order: later patches touch
mods/chat/main.js after earlier ones, so 02-04 expect 01 (and each other) in place.

01-chat-589-592-news-fold-escape-first-message.patch   chat/log.js, chat/main.js
   Four chat fixes, upstream eliasstravik/shepherdr #589 (template <herdr-news> examples read as
   news), #590 (folded "Show more" reply blanks the list), #591 (typed <word> dropped from the
   bubble), #592 (first message folded into "New session" after reopen).
02-chat-633-focus-steal-tasks-thread.patch              chat/main.js
   #633: the Assistant chat no longer takes the keyboard back while a task's chat in the Tasks
   panel has it.
03-chat-tasks-634-focusable-tasks-panel.patch           chat/main.js, chat/mod.json, tasks/main.js, tasks/mod.json
   #634: "focusable" Tasks list and task chat, so pane.go (nvim-nav Ctrl+H/J/K/L) reaches the panel.
04-chat-local-translucent-background.patch              chat/main.js
   Personal, not upstream: chat background at 75% alpha so the layout's wallpaper shows through.
05-artifacts-guide-image-sizing.patch                   artifacts/ARTIFACTS.md
   Image-sizing rule in the herdr-artifact guide. Upstream issue drafted, not filed yet.

Check: patch -d ~/.config/herdr-app/mods -p1 -N --dry-run < NN-*.patch
"Reversed (or previously applied) patch detected" means it's already in (applied, or upstream took it).
After `shepherdr update`, Shepherdr keeps these files (changed) and drops its new copies as *.new:
compare those before re-applying.

Added 2026-11-06:
06-chat-browser-host-stuck-hidden-after-restart.patch   chat/main.js, chat/browserfix.js (new)
   The task header mends a Browser view left hidden with no viewer after a restart. Upstream
   issue drafted, not filed yet.
07-tasks-panel-browser-closed-as-idle.patch             tasks/bin/herdr_task/browsers.py
   A browser being watched in the panel (.view fresh) counts as used, so it isn't closed as idle.
   Upstream issue drafted, not filed yet. The herdr-automations scheduler re-execs itself when
   herdr-task's code changes, so no restart is needed.
