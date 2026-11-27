# Desktop PC user layer (home-manager inside nixos-desktop.nix). Shared packages: home.nix.
# Packages land in /etc/profiles/per-user/brian/bin. Switch with the system:
#   sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix
{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  home.username = "brian";
  home.homeDirectory = "/home/brian";

  dotfiles.linuxDesktop = true; # links.nix: Hyprland and friends' configs

  home.packages = with pkgs; [
    # Build tools nvim plugins use at install time (the Mac gets these from Xcode).
    gcc
    gnumake
    unzip

    # Hyprland session pieces (configs in .config/hypr, linked by links.nix)
    kitty # terminal (SUPER+Enter)
    waybar # top bar
    mako # notifications
    hyprpaper # wallpaper
    hyprlock # lock screen (SUPER+Escape)
    hypridle # locks and sleeps when idle
    hyprpolkitagent # password prompts for apps that need root
    wl-clipboard # wl-copy/wl-paste; nvim's clipboard uses them
    grim # screenshots...
    slurp # ...of a selected region
    satty # annotate a screenshot
    brightnessctl
    playerctl # media keys
    pavucontrol # audio devices and volumes
    networkmanagerapplet # nm-applet in the bar
    nautilus # file manager
    loupe # image viewer

    # Apps
    discord
    lutris # non-Steam launchers (HoYoPlay, Kuro, ...)
    heroic # Epic and GOG
    mangohud # FPS overlay: `mangohud %command%` in Steam
  ];

  # Launcher on SUPER+Space, Raycast-style: apps, open windows across workspaces ("Switch Windows"),
  # calculator, emoji, files, clipboard history (SUPER+CTRL+V), and the Hyprland actions in .config/vicinae/scripts (linked by links.nix).
  # mutableSettings: the keys below win, but changes made in Vicinae's settings window are kept
  # (they go to ~/.config/vicinae/settings.json, which isn't tracked).
  programs.vicinae = {
    enable = true;
    systemd.enable = true; # background server, so the window opens instantly
    mutableSettings = true;
    settings = {
      telemetry.system_info = false;
      theme.dark.name = "rose-pine-moon"; # ships with Vicinae
      theme.light.name = "rose-pine-moon"; # the GTK theme is always dark anyway
      pop_to_root_on_close = true; # opens on a fresh search each time, like Raycast
      launcher_window = {
        rounding = 18; # matches waybar's tabs and mako
        opacity = 0.95; # Hyprland's blur shows through
        # "exclusive" (Vicinae's default): it holds the keyboard while open. "on_demand" let Hyprland's
        # follow_mouse hand focus to whatever window was under the pointer. Vicinae warns that exclusive
        # can break mouse clicks in popups (the Ctrl+B action panel) on Hyprland; the keyboard still works.
        # If that bites, the fallback is a regular window with Hyprland's stay_focused rule.
        layer_shell.keyboard_interactivity = "exclusive";
      };
      # Start apps as part of the uwsm session (own systemd scope, stop at logout), as fuzzel did.
      # Shows under Settings → Extensions → Applications → Launch prefix.
      providers.applications.preferences.launchPrefix = "uwsm app --";
    };
  };

  # Dark theme for GTK apps, and a cursor that matches across apps.
  gtk = {
    enable = true;
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
  };
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
