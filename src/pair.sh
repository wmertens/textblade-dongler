#!/bin/bash
# Use bluetoothctl to pair because cannot make hcitool pair with a BLE keyboard
# Unfortunately, that means bidirectional talking to the program
# TODO present menu with devices to pair
# TODO robustness when pairing fails etc
# TODO auto-switch HID mode devices

HCIDEV=hci0

info() { echo -- "$@" >&2; }

echo -n "waiting for dongle"
while ! lsusb | grep -q -e 0a12:0001 -e 04bf:100b -e 04bf:0320; do
    if which csr-hid2hci > /dev/null ; then
	csr-hid2hci | grep -v 'No device in HID mode found'
    else
	if which hid2hci > /dev/null ; then
	    hid2hci | grep -v 'No device in HID mode found'
	else
	    info "ERROR:  No hid2hci command available"
	    exit 1
	fi
    fi
    
  echo -n .
  sleep 1
done
echo

declare -A ahci

ahci=()
pipe=/tmp/hcitool$$
trap "rm -f $pipe" EXIT

if [[ ! -p $pipe ]]; then
    echo  mkfifo $pipe
fi

hcitool dev > $pipe 2> /dev/null
while read -t 1 line
do
    case $line in
	hci*)
	    strs=($line)
	    echo "	hci[${strs[0]##hci}]: " ${strs[1]}
	    ahci+=([${strs[0]}]="${strs[1]}")
	    # echo "hci[${strs[0]}]: "${hci[${strs[0]}]}
	    ;;
	*)
	    echo "$line"
	    ;;
    esac
    
done < $pipe

if hcitool dev | grep "hci" | wc -l > 1 ; then
    echo "There are multiple HCI devices."
    echo "Which HCI device do you want to use?"
    while read HCIDEV
    do
	if [[ "${ahci[hci$HCIDEV]}" == '' ]] ; then
	    echo "Invalid device [$HCIDEV].  Please enter the correct hci device number?"
	else
	    HCIDEV=hci${HCIDEV}
	    break
	fi
    done
fi
CONTROLLER=${ahci[$HCIDEV]}

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

waitForSilent() {
  local line="" cond="$*"
  info "waiting for $cond"
  while line=$(getLine); ! grep -qE "$cond" <<<"$line"; do
    [ "$line" != $NOTHING ] && true # echo "btctl> $line" >&2
  done
  echo "$line"
}

cmd select $CONTROLLER
waitFor "Controller"
cmd select $CONTROLLER
waitFor "Controller"
cmd power on
waitFor "Changing"

if ! bccmd -d $HCIDEV psget 0x3cd > /dev/null; then
  info "Unfortunately, your dongle is not capable of HID mode :-("
  cmd quit
  wait
  exit 1
fi

cmd scan on
devLine=$(waitFor "TextBlade")
set -- $devLine
dev=$4
cmd scan off
cmd agent KeyboardDisplay
cmd agent on
cmd pair $dev
pin=$(waitFor "Passkey:")
echo $pin

paired=$(waitForSilent "Paired:")
echo $paired
cmd quit
wait
echo Dev is $dev
echo Now run make-hid.sh $dev
echo "If you type 'OK' now, I will run it for you"
echo -n "OK? > "
read ok
echo
if [ "${ok,,}" = "ok" ]; then
  make-hid.sh $dev $HCIDEV
else
  echo "Not running make-hid."
fi
