# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, meta, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
        ];

    nix = {
        package = pkgs.nixFlakes;
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
        };
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.grub.enable = true;
    boot.loader.systemd-boot.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    networking.hostName = meta.hostname; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Set your time zone.
    time.timeZone = "Europe/Amsterdam";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
        #useXkbConfig = true; # use xkb.options in tty.
    };

    # Fixes for longhorn
    systemd.tmpfiles.rules = [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];
    virtualisation.docker.logDriver = "json-file";

    # Enable the X11 windowing system.
    # services.xserver.enable = true;

    # Configure keymap in X11
    # services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable sound.
    # sound.enable = true;
    # hardware.pulseaudio.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with 'passwd'.
    users.users.zepzeper = {
        isNormalUser = true;
        extraGroups = [ "wheel", "networkmanager" ]; # Enable 'sudo' for the user.
        # Created using mkpasswd
        hashedPassword = "$6$xnM6/F7Rycq7CBs4$G1BbDBSdZjb2H0RZxucfTSntTvPSpxyXMHGOGKAyQ7rQZ6UkURBeYZHB6RraDQ8agQasqV67GHTZxu2vGRkSs1";
        openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIqpB/5yibCGEyapq1tjvUQ6Iddgq+n6KBH5i8/S5ysWiWtva7AtSPLjVhgdooZtMKO+bT1sHFC/Iu5MPzY62F/3WOPqKIVzDiJsvoL1st2g+n64fEIcrUhydW3vOUSRGe4vO6LF8HG3scmYy7KOvKv1/eN3g9sAelDHp3Y3bWdeFGmz4D0toIg/g5q4/qTJBetfEBYBuJ060HIYoIgY/xteJRviRSuD/nFIAmEfiRPL318HUcnPBcw9Lc0fWRFjO6YDAvoJ6wz3kV3xIyjV4UTRTxLWNYnKHd49Ig2G1LoBZ/REaGw3+8DbSjPvUHXJ6NJ2YcnxQI35Mj1HdUXVwHF4JL6vn9QyGr1iNNuVctoj8PXPlU3zRdNcPWgf7elWAKd7lBiQxv781C8cOWOVC9TWAZsxvcroTLQ0iwt+tfxk6r9HCT6vMHQqPVUpUdZ9xh96nqOB/jh2jpsx1n9F7Fbwx7coDpOTFHMaMjBIou2Gr2Km3UnekZ58eFaWA2RUE= wouter@MBP-van-Wouter.domain_not_set.invalid"
        ];
    };

    # List packages installed in system profile. To search, run:
    environment.systemPackages = with pkgs; [
        neovim
        k3s
        cifs-utils
        nfs-utils
        git
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
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ 80 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "23.11"; # Did you read the comment?
}
