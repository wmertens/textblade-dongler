{ stdenv, lib, libusb1, writeTextFile }:

let
  pair = ./pair.sh;
  makeHid = ./make-hid.sh;

in stdenv.mkDerivation {
  name = "csr-pairing-1.0.0";

  # We have nothing to unpack
  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    cp ${pair} $out/bin/pair.sh
    cp ${makeHid} $out/bin/make-hid.sh
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "Scripts to pair CSR8510";
    maintainers = with maintainers; [ wmertens ];
    platforms   = with platforms; linux;
    license     = licenses.mit;
  };
}
