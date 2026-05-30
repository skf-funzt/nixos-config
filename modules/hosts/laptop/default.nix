# modules/hosts/laptop/default.nix
# Framework Laptop 13 AMD (7040 series)
{ self, inputs, config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    self.nixosModules.system-btrfs-laptop
    self.nixosModules.desktop-gnome
    self.nixosModules.desktop-niri
    self.nixosModules.user-stephan
  ];

  # ── Bootloader ───────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hibernation resume from LUKS (update <OFFSET> after install)
  # boot.resumeDevice = "/dev/mapper/cryptroot";
  # boot.kernelParams = [ "resume_offset=<OFFSET>" ];

  # ── Kernel ───────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Networking ───────────────────────────────────────────────
  networking.hostName = "framework-stephan";
  networking.networkmanager.enable = true;

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

  # ── Console / Keymap ─────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── Audio ────────────────────────────────────────────────────
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Printing ─────────────────────────────────────────────────
  services.printing.enable = true;

  # ── VM Guest (useful for Boxes/QEMU) ───────────────────────
  services.spice-webdavd.enable = true;
  services.spice-vdagentd.enable = true;

  # ── Root ─────────────────────────────────────────────────────
  users.users.root = {
    initialPassword = "root";
  };

  # ── Packages ─────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    alacritty
    oh-my-posh
    starship
    btop
    amdgpu_top
    fastfetch
    git-extras
    neovim
    gh
    powertop
    fira-code-nerdfont
    fira-code
    roboto
    google-chrome
    vscode
    nil
    spotify
    drawing
    gimp
    inkscape
    krita
    darktable
    blender
    kdePackages.kdenlive
    obs-studio
    discord
    distrobox
    podman-desktop
    yazi
    tldr
    websocat
    stress
  ];

  # ── Programs ─────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.direnv.enable = true;
  programs.tmux.enable = true;
  powerManagement.powertop.enable = true;
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.prompt.enable = true;

  # ── Virtualisation ───────────────────────────────────────────
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;

  # ── Nix Settings ─────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # ── State Version ────────────────────────────────────────────
  system.stateVersion = "26.05";
}
