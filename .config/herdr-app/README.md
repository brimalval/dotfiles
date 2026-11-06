# herdr-app

Pieces of `~/.config/herdr-app` kept in dotfiles. Each is symlinked in place:

```sh
cd ~/.config/herdr-app
ln -sfn ~/Projects/dotfiles/.config/herdr-app/settings.json settings.json
ln -sfn ~/Projects/dotfiles/.config/herdr-app/keys.json keys.json
ln -sfn ~/Projects/dotfiles/.config/herdr-app/layouts/my-main.json layouts/my-main.json
```

Re-run these after a fresh install, or after `shepherdr uninstall` (it
rewrites `keys.json` as a plain file).

`layouts/shepherdr.json` is **not** kept here: it's a plain file owned by
Herdr/Shepherdr, and the Tasks panel mods rewrite it at runtime (which
terminal the task thread shows, the browser viewer, ...). Our look changes live
in `herdr-layout-look` instead (see below).

## Wallpaper background (kitty look)

The shepherdr layout uses a blurred copy of the macOS wallpaper as its
background (`backgrounds/wallpaper-blur.jpg`), with terminals at
`terminal_opacity` 0.75 and no pane-frame background, so it looks like kitty's
`background_opacity 0.75` + `background_blur 20`.

`herdr-layout-look` applies those three changes to the live
`layouts/shepherdr.json` (in place, idempotent). Run it on a new machine, after
`shepherdr update`, or after taking `layouts/shepherdr.json.new` (Shepherdr's
updater writes that beside an edited layout instead of replacing it):

```sh
mv ~/.config/herdr-app/layouts/shepherdr.json.new ~/.config/herdr-app/layouts/shepherdr.json
herdr-layout-look           # apply the overrides
herdr-layout-look --check   # report; exits 1 if any are missing
```

Bake the image after changing the wallpaper (and on a new machine):

```sh
herdr-wallpaper            # writes backgrounds/wallpaper-blur.jpg
herdr-wallpaper --restart  # same, then reopens Herdr so it shows
```

Herdr caches the image while its window is open, so a new one shows only on
Herdr's next start. Tune with `HERDR_WALLPAPER_BLUR` (default 30).
