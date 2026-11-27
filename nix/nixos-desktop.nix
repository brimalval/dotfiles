# Desktop PC (bare-metal NixOS on the 2 TB SSD, dual-booting Windows on the other drive).
# System layer; the user layer is home-nixos-desktop.nix. Hardware (disks, kernel modules) is
# hardware-desktop.nix, generated at install. Switch with:
#   sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix
# (nixos-rebuild picks nixosConfigurations.<hostname>, here "desktop")
{ config, lib, pkgs, ... }:

let
  # Secure Boot via lanzaboote. Install with this false (plain systemd-boot, Secure Boot off in firmware),
  # then follow "Secure Boot" in README.md and flip it to true. Windows' Vanguard needs Secure Boot on.
  secureBoot = false;
in
{
  imports = [ ./hardware-desktop.nix ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true; # NVIDIA driver, Steam

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "brian" ];
  };

  networking.hostName = "desktop";
  networking.networkmanager.enable = true; # `nmtui` in a terminal; nm-applet in the bar

  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_US.UTF-8";
  # Windows keeps the hardware clock in local time; without this the clock is 8 h off after each switch.
  time.hardwareClockInLocalTime = true;

  # --- Boot ---
  # Linux has its own EFI partition on the 2 TB drive. Windows is chosen from the firmware's boot menu
  # (F8/F11/F12 at power-on, depending on the board) or by making it first in the firmware's boot order.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = !secureBoot;
    configurationLimit = 10; # keep the EFI partition from filling up with old generations
  };
  boot.lanzaboote = lib.mkIf secureBoot {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- NVIDIA (RTX 3060 Ti, Ampere: NVIDIA's open kernel modules are the recommended ones) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit games and Steam itself
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true; # required by Wayland compositors
    powerManagement.enable = true; # saves VRAM across suspend, so apps don't come back corrupted
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # --- Desktop: Hyprland, with Plasma as a fallback session; pick either at the login screen ---
  programs.hyprland = {
    enable = true;
    withUWSM = true; # starts Hyprland as a systemd session, so services and env vars behave
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Electron/Chromium apps (Discord, VS Code) run on Wayland

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # stores secrets for browsers, VS Code, gh
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.hyprlock = { }; # lets hyprlock check your password

  # --- Audio, Bluetooth, printing ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Gaming ---
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # a "Steam Big Picture" session at the login screen
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # GE-Proton: fixes some games stock Proton doesn't
  };
  programs.gamescope.enable = true; # wrap misbehaving games: `gamescope -f -- %command%` in Steam
  programs.gamemode.enable = true; # `gamemoderun %command%`: CPU governor and priority while playing

  # --- Fonts ---
  fonts.packages = [
    pkgs.maple-mono.variable
    pkgs.maple-mono.NF # kitty's font_family
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans # Japanese/Chinese text in games and on the web
    pkgs.noto-fonts-color-emoji
  ];

  # --- User ---
  programs.zsh.enable = true; # system-wide, so /etc/shells lists it; the repo's .zshrc does the rest
  users.users.brian = {
    isNormalUser = true;
    description = "Brian";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    git # flakes need it, and so does root reading this repo
    sbctl # Secure Boot keys (lanzaboote)
    ntfs3g # read the Windows drive
    pciutils
    usbutils
  ];

  # Prebuilt Linux binaries (Mason's language servers, npm native modules).
  programs.nix-ld.enable = true;

  programs.firefox.enable = true;

  # Set at first install; don't bump. It isn't the NixOS version you run.
  system.stateVersion = "26.11";
}
