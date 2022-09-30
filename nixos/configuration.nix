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
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions
      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      zig.overlays.default
      neovim-nightly-overlay.overlays.default

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
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  console.keyMap = "br-abnt2";
  networking.extraHosts = ''
    127.0.0.1 cluster.local
    127.0.0.1 elgin.cluster.local
    127.0.0.1 metabase.cluster.local
    127.0.0.1 monitoring.cluster.local
    127.0.0.1 registry.cluster.local
    127.0.0.1 docker-registry.cluster.local
    127.0.0.1 notary.cluster.local
  '';

  networking.hostName = "hades";
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

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

  environment.systemPackages = with pkgs; [
    ntfs3g
    alacritty
    kitty
    wezterm
    kakoune
    helix
    tdesktop
    wget
    unzip
    tree-sitter
    neovim
    lazygit
    gdu
    bottom-rs
    zig
    zls
    rustup
    unrar
    gnupg
    nixfmt
    elixir_ls
    erlang
    erlang-ls
    elixir
    swiProlog
    scryer-prolog
    sbcl
    go
    jq
    yq
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
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    fzf
    fd
    zstd
    python3
    nodePackages.prettier
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
      videoDrivers = [ "nvidia" ];
    };
    earlyoom.enable = true;
    flatpak.enable = true;
  };

  zramSwap.enable = true;
  programs.steam.enable = true;
  programs.bash.promptInit = ''
    # Provide a nice prompt if the terminal supports it.
             if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
               PROMPT_COLOR="1;31m"
               ((UID)) && PROMPT_COLOR="1;32m"
               if [ -n "$INSIDE_EMACS" ] || [ "$TERM" = "eterm" ] || [ "$TERM" = "eterm-color" ]; then
                 # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
                 PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
               else
                 PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
               fi
               if test "$TERM" = "xterm"; then
                 PS1="\[\033]2;\h:\u:\w\007\]$PS1"
               fi
             fi'';

  system.stateVersion = "22.05";
}
