# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      inputs.neovim-nightly-overlay.overlay
      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      trusted-users = [ "drakonis" ];
      substituters = [
        "https://nyx.chaotic.cx"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  console.keyMap = "br-abnt2";
  networking.extraHosts = ''
    127.0.0.1 loki.infra.cluster.test
    127.0.0.1 prometheus.infra.cluster.test
    127.0.0.1 monitoring.infra.cluster.test
    127.0.0.1 auth.infra.cluster.test
    127.0.0.1 traefik.infra.cluster.test
    127.0.0.1 traefik-shellhub.infra.cluster.test
    127.0.0.1 hubble.infra.cluster.test
    127.0.0.1 sentry.infra.cluster.test
    127.0.0.1 gerrit.cluster.test
    127.0.0.1 shellhub.cluster.test
    127.0.0.1 site.cluster.test
  '';

  networking.hostName = "hades";
  boot = {
    #kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        #efiInstallAsRemovable = true;
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.utf8";

  environment.systemPackages = with pkgs;
    [
      wineWowPackages.unstable
      proton-caller
      steamtinkerlaunch
      xxd
      rlwrap
      vscode
      gamemode
      helix
      ntfs3g
      alacritty
      kitty
      wezterm
      gdb
      gnumake
      fasm
      fasmg
      gforth
      tdesktop
      wget
      unzip
      tree-sitter
      neovim
      lazygit
      git-lfs
      xdotool
      gdu
      bottom-rs
      unrar
      gnupg
      nixpkgs-fmt
      go
      jq
      yq-go
      kube3d
      kubectl
      fluxcd
      kubectx
      kubernetes-helm
      firefox
      libreoffice
      kate
      ark
      vlc
      tmux
      qbittorrent
      ((emacsPackagesFor emacs-gtk).emacsWithPackages
        (epkgs: [ epkgs.vterm epkgs.emacsql-sqlite ]))
      htop
      ncdu
      keepassxc
      git
      anydesk
      gcc
      binutils
      starsector
      git
      xorg.libX11
      (ripgrep.override { withPCRE2 = true; })
      gnutls
      fzf
      fd
      zstd
      python3
      k9s
      nodejs
      xclip
    ];

  users.users = {
    drakonis = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };

  virtualisation.docker.enable = true;
  sound.enable = true;
  hardware = {
    pulseaudio.enable = false;
    opengl.enable = true;
    xone.enable = true;
  };
  security.rtkit.enable = true;

  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    xserver = {
      enable = true;
      layout = "br";
      xkbVariant = "";

      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      #videoDrivers = [ "nvidia" ];
    };
    earlyoom.enable = true;
    flatpak.enable = true;
  };
  fonts.fonts = with pkgs; [
    #noto-fonts
    #noto-fonts-cjk
    #noto-fonts-emoji
    #liberation_ttf
    #fira-code
    #fira-code-symbols
    #mplus-outline-fonts.githubRelease
    #dina-font
    #proggyfonts
    nerdfonts
  ];
  zramSwap.enable = true;
  services.envfs.enable = true;
  programs.steam.enable = true;
  programs.dconf.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      gamemode
      zlib
      fuse3
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libpulseaudio
      libuuid
      xorg.libxcb
      libxkbcommon
      mesa
      nspr
      nss
      pango
      pipewire
      systemd
      icu
      openssl
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxkbfile
      xorg.libxshmfence
      vulkan-loader
      zlib
      zstd
      curl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
    ];
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
