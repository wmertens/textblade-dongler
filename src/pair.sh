#!/bin/sh
# Use bluetoothctl to pair because cannot make hcitool pair with a BLE keyboard
# Unfortunately, that means bidirectional talking to the program
# TODO present menu with devices to pair
# TODO robustness when pairing fails etc
# TODO auto-switch HID mode devices

info() { echo -- "$@" >&2; }

echo -n "waiting for dongle"
while ! lsusb | grep -q -e 0a12:0001 -e 04bf:100b; do
  echo -n .
  sleep 1
done
echo

info starting bluetoothctl
coproc bluetoothctl

cmd() {
  echo "> $*"
  echo "$@" >&${COPROC[1]}
}
NOTHING=__N0L1NE__
getLine() { local a; read -t 1 -ru ${COPROC[0]} a; (( $? > 127 )) && echo $NOTHING || echo "$a"; }
waitFor() {
  local line="" cond="$*"
  info "waiting for $cond"
  while line=$(getLine); ! grep -qE "$cond" <<<"$line"; do
    [ "$line" != $NOTHING ] && echo "btctl> $line" >&2
  done
  echo "$line"
}

waitFor "Controller"
cmd power on
waitFor "Changing"
cmd scan on
devLine=$(waitFor "TextBlade")
set -- $devLine
dev=$4
cmd pair $dev
paired=$(waitFor "Paired:")
echo $paired
cmd quit
wait
echo Dev is $dev
echo Now run make-hid.sh $dev
echo "If you type 'OK' now, I will run it for you"
echo -n "OK? > "
read ok
echo
if [ "$ok" = "OK" ]; then
  make-hid.sh $dev
else
  echo "Not running make-hid."
fi
