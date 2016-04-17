{ stdenv, lib, libusb1, writeTextFile }:

let
  source = ./hid2hci.c;

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
