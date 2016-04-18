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
    '';

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
