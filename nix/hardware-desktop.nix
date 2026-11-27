# Desktop hardware: Ryzen 5 5600X, ASUS TUF B450M-PRO II, RTX 3060 Ti.
# Stand-in until install day: replace it with the output of `nixos-generate-config --show-hardware-config`
# (README.md → "Install the desktop"). The disks are found by the labels the install steps give them,
# so this works as is if the steps are followed.
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # nvme: the SSD in an M.2 slot; xhci_pci, usb_storage, uas: the same SSD in its USB enclosure.
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "uas" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
  zramSwap.enable = true; # compressed swap in RAM; 16 GB plus this is plenty without a swap partition

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
