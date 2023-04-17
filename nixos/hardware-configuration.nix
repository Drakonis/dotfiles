{ config, lib, pkgs, modulesPath, ... }: {

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/09b85c52-f26d-4d93-87fc-7271376831c9";
    fsType = "ext4";
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/104e83dc-ba40-465c-a112-b3cb7ee8c22c";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/8B6D-1DAF";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Set your system kind (needed for flakes)
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
