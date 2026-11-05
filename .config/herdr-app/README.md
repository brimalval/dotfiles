# herdr-app

Pieces of `~/.config/herdr-app` kept in dotfiles. Each is symlinked in place:

```sh
cd ~/.config/herdr-app
ln -sfn ~/Projects/dotfiles/.config/herdr-app/settings.json settings.json
ln -sfn ~/Projects/dotfiles/.config/herdr-app/keys.json keys.json
ln -sfn ~/Projects/dotfiles/.config/herdr-app/layouts/shepherdr.json layouts/shepherdr.json
ln -sfn ~/Projects/dotfiles/.config/herdr-app/layouts/my-main.json layouts/my-main.json
```

Re-run these after a fresh install, or after `shepherdr uninstall` (it
rewrites `keys.json` as a plain file). `shepherdr update` leaves an edited
`layouts/shepherdr.json` alone and writes `shepherdr.json.new` beside it.

## Wallpaper background (kitty look)

`layouts/shepherdr.json` uses a blurred copy of the macOS wallpaper as its
background (`backgrounds/wallpaper-blur.jpg`), with terminals at
`terminal_opacity` 0.75 and no pane-frame background, so it looks like kitty's
`background_opacity 0.75` + `background_blur 20`.

Bake the image after changing the wallpaper (and on a new machine):

```sh
herdr-wallpaper            # writes backgrounds/wallpaper-blur.jpg
herdr-wallpaper --restart  # same, then reopens Herdr so it shows
```

Herdr caches the image while its window is open, so a new one shows only on
Herdr's next start. Tune with `HERDR_WALLPAPER_BLUR` (default 30).
