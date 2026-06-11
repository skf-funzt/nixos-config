# modules/hosts/laptop/default.nix
# Framework Laptop 13 AMD (7040 series)
{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.dms.nixosModules.dank-material-shell
    ../../system/disko-laptop.nix # Declarative disk partitioning (replaces btrfs-laptop.nix)
    ../../system/ensure-btrfs-subvolumes.nix # Subvolume helper
    ../../desktop/gnome.nix
    ../../desktop/niri.nix
    ../../users/stephan.nix
  ];

  # ── Bootloader ───────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hibernation — swap on LUKS-encrypted partition (cryptswap).
  # resumeDevice is set to /dev/mapper/cryptswap by disko's resumeDevice = true.
  #
  # The keyfile is stored on root at /etc/cryptswap.key AND baked into the initrd
  # at build time via boot.initrd.secrets. This avoids a circular dependency during
  # resume from hibernation: the keyfile is available in the initrd's tmpfs before
  # any filesystem is mounted, so cryptswap can unlock before root.
  #
  # If the keyfile doesn't exist at build time (fresh disko install), the build
  # will fail with a clear error. Run convert-swap-to-luks.sh to set up the keyfile,
  # then rebuild.
  #
  # NOTE: nixos-rebuild/nh must be run with --impure for the keyfile to be read
  # from /etc/cryptswap.key (flakes block access to absolute paths by default).
  # This is the standard approach for initrd secrets.
  boot.initrd.secrets = {
    "/etc/cryptswap.key" = "/etc/cryptswap.key";
  };

  boot.initrd.luks.devices.cryptswap = {
    device = "/dev/disk/by-partlabel/disk-main-swap";
    keyFile = "/etc/cryptswap.key";
    allowDiscards = true;
  };

  # ── Kernel ───────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Networking ───────────────────────────────────────────────
  networking.hostName = "framework-stephan";
  networking.networkmanager.enable = true;
  networking.wireless = {
    enable = true;
    userControlled = true;
  };
  # ── Power / Hibernation ────────────────────────────────────
  # Power button suspends (safer than hibernate for laptop),
  # lid close suspends, lid on external power does nothing.
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  # Suspend-then-hibernate: after 1 hour suspended, hibernate to save battery.
  systemd.sleep.settings.Sleep = {
    AllowHibernation = "yes";
    HibernateDelaySec = "3600";
  };

  # ── Locale / Time ────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # ── Console / Keymap / X11 ───────────────────────────────────
  services.xserver = {
    enable = true;
    exportConfiguration = true; # Required for Wayland/GNOME to read XKB options
    xkb = {
      layout = "us"; # Change to your layout
      options = "compose:ralt"; # Sets Right Alt as the Compose Key
    };
  };

  # ── Audio ────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Printing ─────────────────────────────────────────────────
  services.printing.enable = true;
  services.printing.drivers = [
    # pkgs.gutenprint
    # pkgs.gutenprintBin
    pkgs.cups-bjnp # This contains the the driver for Canon MX450
    # pkgs.canon-cups-ufr2
    # pkgs.carps-cups
  ];
  # ── VM Guest (useful for Boxes/QEMU) ───────────────────────
  # services.spice-webdavd.enable = true;
  # services.spice-vdagentd.enable = true;

  # ── Root ─────────────────────────────────────────────────────
  users.users.root = {
    initialPassword = "root";
  };

  # ── Packages ─────────────────────────────────────────────────
  nixpkgs.config = {
    allowUnfree = true;
    #   permittedInsecurePackages = [
    #     "electron-39.8.10"
    #   ];
  };

  environment.systemPackages = with pkgs; [
    vim
    kitty
    oh-my-posh
    starship
    btop
    amdgpu_top
    fastfetch
    git-extras
    neovim
    gh
    powertop
    nerd-fonts.fira-code
    fira-code
    roboto
    # google-chrome
    # vscode
    nil
    # spotify
    # drawing
    # gimp
    # inkscape
    # krita
    # darktable
    # blender
    # kdePackages.kdenlive
    # obs-studio
    # discord
    # distrobox
    podman-desktop
    yazi
    tldr
    websocat
    stress
    pciutils
    usbutils
  ];

  # ── Programs ─────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.direnv.enable = true;
  programs.tmux.enable = true;
  powerManagement.powertop.enable = true;

  # Prevent USB autosuspend for wireless mouse receiver (fixes ~1s lag)
  services.udev.extraRules = ''
    # Logitech USB Receiver — disable autosuspend to prevent mouse stutter
    SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c53f", ATTR{power/control}="on"
  '';

  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.prompt.enable = true;

  # ── DankMaterialShell ────────────────────────────────────────
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # ── Virtualisation ───────────────────────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # docker CLI → podman
    # dockerSocket disabled — creates ROOT-scoped socket.
    # Docker API clients use /var/run/docker.sock → user rootless socket.
    dockerSocket.enable = false;
  };
  # ── Docker Socket Compat (→ rootless podman) ────────────────────
  # Symlink /var/run/docker.sock → user's rootless podman socket.
  # Docker API clients (supabase, lazydocker, etc.) hit this path.
  systemd.services.podman-docker-socket = {
    description = "Docker Socket Compat (→ rootless podman)";
    after = [ "user@1000.service" ];
    wants = [ "user@1000.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/ln -sf /run/user/1000/podman/podman.sock /var/run/docker.sock";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # ── Snapshots (Snapper + Btrfs) ───────────────────────────────
  # Bind-mount @snapshots to /.snapshots so snapper can use it
  fileSystems."/.snapshots" = {
    device = "/snapshots";
    options = [ "bind" ];
    fsType = "none";
  };

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs = {
      # Root is reproducible via flake — no snapshots needed
      root = {
        SUBVOLUME = "/";
        TIMELINE_CREATE = false;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 0;
        TIMELINE_LIMIT_DAILY = 0;
        TIMELINE_LIMIT_WEEKLY = 0;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
      };
      # Home is the only irreplaceable data
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "stephan" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 12;
        TIMELINE_LIMIT_YEARLY = 1;
      };
    };
  };

  # ── Ephemeral subvolumes (excluded from home snapshots) ──────
  # Managed by modules/system/ensure-btrfs-subvolumes.nix.
  boot.btrfs.ensureSubvolumes = [
    {
      path = "/home/stephan/.cache";
      owner = "stephan:users";
    }
    {
      path = "/home/stephan/.local/share";
      owner = "stephan:users";
    }
    {
      path = "/home/.snapshots";
      owner = "root:root";
    }
  ];

  # v rules keep converted dirs as subvolumes across rebuilds.
  # Snapper needs this dir to exist on the @home subvolume.
  systemd.tmpfiles.rules = [
    "v /home/stephan/.cache        0700 stephan users -"
    "v /home/stephan/.local/share  0700 stephan users -"
  ];

  # ── Nix Settings ─────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # ── Home Manager Special Args ────────────────────────────────
  home-manager.extraSpecialArgs = {
    inherit inputs pkgs-unstable;
    nixgl = inputs.nixgl;
    handy = inputs.handy;
    khanelivim = inputs.khanelivim;
    gpuType = "amd";
    dms = inputs.dms;
    nixvim = inputs.khanelivim;
  };

  # ── Home Manager Shared Modules ──────────────────────────────
  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    inputs.dms.homeModules.dank-material-shell
  ];

  # ── State Version ────────────────────────────────────────────
  system.stateVersion = "26.05";
}
