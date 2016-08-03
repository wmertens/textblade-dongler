{
  dongler = {config, pkgs, ...}: {
    # Minimal install
    environment.noXlibs = true;
    services.xserver.enable = false;
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

    # Skip login prompt
    services.mingetty.autologinUser = "root";
    users.motd = ''
      * Plug in the CSR dongle
      * Switch your TB on a free jump slot
      * Run pair.sh
      * Run the make-hid.sh command it outputs. Make sure that is your TextBlade.
      * You can ssh in to have copy/paste available:
        * Choose a password with `passwd`
        * Examine the output of `ip a | grep inet`
          * You probably need a 192.168 address
        * ssh to root@ip
    '';
    services.openssh.permitRootLogin="yes";

    #  Bluez 5
    hardware.bluetooth.enable = true;
    nixpkgs.config.packageOverrides = pkgs : {
      bluez = pkgs.bluez5;
      csr-hid2hci = pkgs.callPackage ../src/csr-hid2hci.nix {};
      csr-pairing = pkgs.callPackage ../src/csr-pairing.nix {};
    };

    # CLI packages
    environment.systemPackages = with pkgs; [
      csr-hid2hci csr-pairing
      bluez usbutils bc
    ];
  };
}
