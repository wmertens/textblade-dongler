{ stdenv, lib, libusb1, writeTextFile }:

let
  source = writeTextFile {
    name = "hid2hci.c";
    text = ''
      #include <stdio.h>
      #include <libusb-1.0/libusb.h>

      int main (int argc, char ** argv) {
        char data[] = { 0x01, 0x05, 0, 0, 0, 0, 0, 0, 0 };
        libusb_init(NULL);
        libusb_device_handle* h = libusb_open_device_with_vid_pid(NULL, 0x0a12, 0x100b);
        if (!h) {
          printf("No device in HID mode found\n");
        } else {
          libusb_detach_kernel_driver(h, 0);
          printf("%d\n", libusb_claim_interface(h, 0));
          libusb_control_transfer(h, LIBUSB_ENDPOINT_OUT|LIBUSB_REQUEST_TYPE_CLASS|LIBUSB_RECIPIENT_INTERFACE, LIBUSB_REQUEST_GET_CONFIGURATION, 0x0301, 0, data, 9, 10000);
          libusb_release_interface(h, 0);
          libusb_close(h);
        }
        libusb_exit(NULL);
        return 0;
      }
    '';
  };
in stdenv.mkDerivation {
  name = "csr-hid2hci-1.0.0";

  buildInputs = [ libusb1 ];

  # We have nothing to unpack
  unpackPhase = "true";

  buildPhase = "$CC ${source} -lusb-1.0 -o csr-hid2hci";

  installPhase = ''
    mkdir -p $out/bin
    cp csr-hid2hci $out/bin
  '';

  meta = with lib; {
    description = "Resets CSR8510 to HCI mode";
    maintainers = with maintainers; [ wmertens ];
    platforms   = with platforms; linux;
    license     = licenses.mit;
  };
}
