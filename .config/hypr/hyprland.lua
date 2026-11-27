-- Hyprland, desktop PC. Linked to ~/.config/hypr by nix/links.nix; edits apply on save.
-- Hyprland 0.57+ reads only this Lua file (hyprland.conf is no longer read, and when this file is missing
-- Hyprland writes a stock example here). Check for mistakes: `hyprctl configerrors`.
-- API reference: the stubs in the Hyprland package, $(dirname $(readlink -f $(command -v Hyprland)))/../share/hypr/stubs/hl.meta.lua
-- Try a call live without binding it: `hyprctl dispatch 'hl.dsp.focus({ workspace = "previous" })'`
--
-- Keys mirror .aerospace.toml, with SUPER in place of alt: on a PC keyboard the Windows key sits where
-- the Mac's option key does, so the same fingers do the same things. SUPER also stays out of games' way.

local terminal = "kitty"
local launcher = "fuzzel"

local function bind(keys, dispatcher, opts) hl.bind(keys, dispatcher, opts) end
local exec = hl.dsp.exec_cmd

-- Run several dispatchers from one key (the old config bound the same key twice for this).
local function chain(...)
  local dispatchers = { ... }
  return function()
    for _, d in ipairs(dispatchers) do hl.dispatch(d) end
  end
end

-- --- Monitors ---
-- Every monitor at its highest refresh rate, placed automatically. List them with `hyprctl monitors`, then
-- pin each one, e.g.:  hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })

-- --- NVIDIA ---
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XCURSOR_SIZE", "24")

-- --- Startup (uwsm app: runs each one as part of the session, so they stop when you log out) ---
hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- waybar")
  hl.exec_cmd("uwsm app -- mako")
  hl.exec_cmd("uwsm app -- hypridle")
  hl.exec_cmd("uwsm app -- nm-applet --indicator")
  hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-- --- Look (AeroSpace had no gaps; same here) ---
hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 2,
    col = {
      active_border = "rgba(c4a7e7ff)",
      inactive_border = "rgba(393552ff)",
    },
    layout = "dwindle",
  },
  decoration = {
    rounding = 0,
    blur = { enabled = true, size = 6, passes = 2 },
  },
  animations = { enabled = true },
  dwindle = { preserve_split = true },
  misc = {
    vrr = 2, -- variable refresh rate (G-Sync/FreeSync) in fullscreen apps, i.e. games
    disable_hyprland_logo = true,
    force_default_wallpaper = 0, -- no anime mascot wallpaper behind empty workspaces
    focus_on_activate = true,
  },
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    accel_profile = "flat", -- no mouse acceleration: what games expect
    sensitivity = 0,
  },
})
hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "default" })

-- --- Apps ---
bind("SUPER + Return", exec("uwsm app -- " .. terminal))
bind("SUPER + Space", exec(launcher .. ' --launch-prefix="uwsm app -- "'))
bind("SUPER + CTRL + V", exec("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
bind("SUPER + Escape", exec("hyprlock"))
bind("Print", exec('grim -g "$(slurp)" - | wl-copy'))                    -- region → clipboard
bind("SHIFT + Print", exec('grim -g "$(slurp)" - | satty --filename -')) -- region → annotate
bind("SUPER + SHIFT + E", exec("uwsm stop"))                             -- log out

-- --- Windows (AeroSpace: alt-...) ---
local dirs = { H = "left", J = "down", K = "up", L = "right" }
for key, dir in pairs(dirs) do
  bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }))
  bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

bind("SUPER + minus", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
bind("SUPER + equal", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })

bind("SUPER + slash", hl.dsp.layout("togglesplit")) -- alt-slash: flip horizontal/vertical
bind("SUPER + comma", hl.dsp.group.toggle())        -- alt-comma: accordion ≈ a tabbed group
bind("SUPER + period", hl.dsp.group.next())         --   next tab in the group
bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + SHIFT + Q", hl.dsp.window.close())

bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })   -- SUPER + drag: move
bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- SUPER + right-drag: resize

-- --- Workspaces: 1-9 and letters, as in AeroSpace (F, Q are taken by fullscreen and close) ---
for i = 1, 9 do
  bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
  bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
-- Letter workspaces are numbered 11-30 behind the scenes and named after their letter. Plain named
-- workspaces (`name:A`) have no id in Hyprland 0.57's workspace list, and Waybar leaves them off the bar.
-- E is left out of SUPER+SHIFT (log out); SUPER+E still goes to workspace E.
local id = 10
for letter in ("ABCDEGIMNOPRSTUVWXYZ"):gmatch(".") do
  id = id + 1
  hl.workspace_rule({ workspace = tostring(id), default_name = letter })
  bind("SUPER + " .. letter, hl.dsp.focus({ workspace = id }))
  if letter ~= "E" then
    bind("SUPER + SHIFT + " .. letter, hl.dsp.window.move({ workspace = id, follow = false }))
  end
end

bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))        -- alt-tab: back and forth
bind("SUPER + SHIFT + Tab", hl.dsp.workspace.move({ monitor = "+1" })) -- alt-shift-tab: workspace to next monitor

-- --- Service mode (AeroSpace: alt-shift-semicolon) ---
local reset = hl.dsp.submap("reset")
bind("SUPER + SHIFT + semicolon", hl.dsp.submap("service"))
hl.define_submap("service", function()
  bind("Escape", chain(hl.dsp.reload_config(), reset))
  bind("F", chain(hl.dsp.window.float({ action = "toggle" }), reset))
  bind("Up", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
  bind("Down", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
  bind("SHIFT + Down", chain(exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0"), reset))
  bind("Q", reset)
end)

-- --- Media keys ---
bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioNext", exec("playerctl next"), { locked = true })
bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })

-- --- Window rules ---
-- Find a window's class with `hyprctl clients`. Game launchers and pop-ups that should float go here, e.g.:
--   hl.window_rule({ name = "float-launcher", match = { class = "^(lutris)$" }, float = true })

-- From Hyprland's stock config: ignore apps asking to maximize themselves, and fix XWayland drag-and-drop.
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
  name = "fix-xwayland-drags",
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})
