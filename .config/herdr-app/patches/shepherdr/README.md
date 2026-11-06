# Local Shepherdr patches

Fixes to Shepherdr's own mods (`chat`, `tasks`, `artifacts`) that aren't
upstream yet, kept as patches. `README.txt` lists each patch and its upstream
issue. They were made against Shepherdr 3.0.0 on herdr-app 0.1.13.

This folder is not a mod and must never be linked into
`~/.config/herdr-app/mods`.

## When to run it

```sh
~/Projects/dotfiles/.config/herdr-app/patches/shepherdr/apply.sh
```

- After a fresh Shepherdr install.
- After `shepherdr update`, once you've replaced a patched file with the
  `*.new` copy it left beside it.

Safe to re-run: patches already in are reported as `already applied` and
skipped. If one doesn't apply it stops and prints the rejected hunks; nothing
is forced. Herdr hot-reloads mods, so no restart. `--mods DIR` (or
`HERDR_APP_HOME`) points it at another tree.

## Which fixes has upstream taken?

```sh
apply.sh --check
```

On a fresh install or a `.new` copy:

- `already applied`: upstream shipped the same change. Delete the patch.
- `DOES NOT APPLY`: upstream changed that code. Look at whether the fix is
  in some other form. If so, delete the patch; if not, refresh it.
- `would apply`: still needed.

## Adding or refreshing a patch

Diff the Shepherdr original against your fixed file, from inside `mods/`,
so the paths come out `a/<mod>/<file>` / `b/<mod>/<file>` (`-p1`):

```sh
cd ~/.config/herdr-app/mods
mkdir -p /tmp/orig/chat && cp chat/main.js.new /tmp/orig/chat/main.js   # or a pristine copy
diff -u /tmp/orig/chat/main.js chat/main.js \
  | sed '1s|^--- .*|--- a/chat/main.js|; 2s|^+++ .*|+++ b/chat/main.js|' \
  > NN-chat-<issue>-<what>.patch
```

Patches are sequential: when a file is touched by several patches (like
`chat/main.js`), the "before" side of a new one is the original with the
earlier patches applied (`apply.sh --mods <copy>` makes one).

Name it `NN-…` so it sorts after the patches it builds on, and add a line to
`README.txt`. Run `apply.sh --check` before committing: every patch should
show `already applied` against your live tree.
