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
    fuzzel # app launcher (SUPER+Space)
    mako # notifications
    hyprpaper # wallpaper
    hyprlock # lock screen (SUPER+Escape)
    hypridle # locks and sleeps when idle
    hyprpolkitagent # password prompts for apps that need root
    wl-clipboard # wl-copy/wl-paste; nvim's clipboard uses them
    cliphist # clipboard history (SUPER+V)
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
