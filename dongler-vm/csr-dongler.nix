{
  dongler = {config, pkgs, ...}: {
    # Minimal install
    environment.noXlibs = true;
    services.xserver.enable = false;
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

    #  Bluez 5
    hardware.bluetooth.enable = true;
    nixpkgs.config.packageOverrides = pkgs : {
      bluez = pkgs.bluez5;
      csr-hid2hci = pkgs.callPackage ../csr-hid2hci.nix {};
    };

    # CLI packages
    environment.systemPackages = with pkgs; [
      csr-hid2hci
      bluez usbutils bc
    ];
  };
}
