# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include the VM configuration
    ./vm.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # This throws an error when KDE is starting
  # services.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # GNOME Boxes
  services.spice-webdavd.enable = true;
  services.spice-vdagentd.enable = true;

  # Root user configuration
  users.users.root = {
    initialPassword = "root"; # Change this to something secure
    # Uncomment to disable root login completely and rely only on sudo:
    # hashedPassword = "!";
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.stephan = {
    isNormalUser = true;
    description = "stephan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "podman"
    ];
    # packages = with pkgs; [

    # ];
    initialPassword = "stephan";
  };

  # Optional: Enable passwordless sudo for wheel group members
  # security.sudo.wheelNeedsPassword = false;

  # Programs
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.direnv.enable = true;

  programs.tmux.enable = true;
  powerManagement.powertop.enable = true;

  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.prompt.enable = true;

  # virtualisation.docker.enable = true;
  # # This option enables docker in a rootless mode, a daemon that
  # # manages linux containers. To interact with the daemon, one needs
  # #  to set DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
  # virtualisation.docker.rootless.enable = true;

  virtualisation.podman.enable = true;
  # Make the Podman socket available in place of the Docker socket,
  # so Docker tools can find the Podman socket.
  # Podman implements the Docker API.
  # Users must be in the podman group in order to connect.
  # As with Docker, members of this group can gain root access.
  virtualisation.podman.dockerSocket.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget

    # zsh
    alacritty
    oh-my-posh
    starship

    btop
    byobu
    amdgpu_top
    fastfetch
    git-extras
    neovim

    github-copilot-cli
    gh

    # nbfc-linux #https://github.com/nbfc-linux/nbfc-linux/blob/main/nixos-installation-new.md
    powertop

    fira-code-nerdfont
    fira-code
    roboto

    google-chrome

    vscode
    # direnv # For the VSCode Nix Extension
    nil # For the VSCode Nix Extension
    # logseq # Does not work because of insecure package 'electron'

    # docker
    # docker-compose
    # docker-buildx

    # podman
    podman-desktop
    # podman-tui

    distrobox
    # distrobox-tui #https://github.com/phanirithvij/distrobox-tui

    discord

    spotify

    drawing
    gimp
    inkscape
    krita
    darktable
    blender
    kdePackages.kdenlive

    obs-studio

    insomnia

    # ventoy
    # yubikey-manager

    # GNOME Extensions
    gnomeExtensions.espresso
    gnomeExtensions.paperwm
    # gnomeExtensions.day-progress // Not in the upstream
    # gnomeExtensions.places-status-indicator
    # gnomeExtensions.screenshot-window-sizer
    gnomeExtensions.astra-monitor
    gnomeExtensions.workspace-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    gnomeExtensions.spotify-tray
    # gnomeExtensions.native-window-placement
    gnomeExtensions.dim-background-windows
    gnomeExtensions.screenshot-window-sizer
    gnomeExtensions.auto-move-windows
    gnomeExtensions.just-perfection
    gnomeExtensions.gnome-40-ui-improvements
    # gnomeExtensions.removable-drive-menu
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.open-bar
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
