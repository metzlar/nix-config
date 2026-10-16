{ config, pkgs, ... }:

let
  homeManager = fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${homeManager}/nixos")
  ];

  home-manager.backupFileExtension = "backup";

  # Automatically remove store objects no longer needed by recent generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Deduplicate identical files in /nix/store.
  nix.settings.auto-optimise-store = true;

  # Bootloader setup using GRUB with EFI and LUKS support
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot"; # Or /boot/efi depending on your mount layout

    grub = {
      enable = true;
      configurationLimit = 10;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = false;
      useOSProber = false;

      extraEntries = ''
        menuentry "Ubuntu (encrypted)" {
          insmod part_gpt
          insmod fat
          search --no-floppy --fs-uuid --set=esp AC8D-3C80
          chainloader ($esp)/EFI/ubuntu/shimx64.efi
        }
      '';

    };
  };

  # Enable Zsh at the operating-system level.
  programs.zsh.enable = true;

  networking.hostName = "ivan-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # set Zsh as the default for ALL users (including root):
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ivan" = {
    isNormalUser = true;
    description = "Ivan Metzlar";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.ivan = import ./ivan.nix;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscode
    codex
  ];

  # Experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05"; # Did you read the comment?

}
