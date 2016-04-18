#!/bin/sh
MAC=$(echo "$1" | tr a-f A-F)
DEV=hci0
CTRL=$(tr a-f A-F </sys/class/bluetooth/$DEV/address)

function die() {
  echo "FATAL: $@" 1>&2
  exit 1
}

[ -z "$CTRL" ] || [ -z "$MAC" ] && die "Call as: $0 keyboard-mac"

infodir="/var/lib/bluetooth/$CTRL/$MAC"
[ -d "$infodir" ] || die "$infodir does not exist, cannot continue"

function readKeys() {
  export Key= EDiv= Rand=
  export t= $(cat "/var/lib/bluetooth/$CTRL/$MAC/info" | sed -n -e '/^\[LongTermKey/,/^\[/p' | grep -E '^(Key|EDiv|Rand)=[A-F0-9]+$')
  if [ -z "$Key" ] || [ -z "$EDiv" ] || [ -z "$Rand" ]; then
    return 1
  fi
  return 0
}

function toHex() { echo "obase=16; $1" | bc; }
function revbytes(){ local b=""; for ((i=2;i<=${#1};i+=2)); do b=$b${1: -i:2}; done; echo $b; }
function rev16(){ local b=""; for ((i=0;i<${#1};i+=4)); do b=$b${1: i+2:2}${1: i:2}; done; echo $b; }
function pad() { local b=000000000000000000000000000000000000000000000000000000$1; echo ${b: -$2*2:$2*2}; }
function makeToken() { echo $(echo $MAC|tr -d : )1482$(rev16 $(pad $(toHex $EDiv) 2))$(revbytes $(pad $(toHex $Rand) 8))$(rev16 $(pad $Key 16)); }
function formatToken() { local b=""; for ((i=0;i<${#1};i+=4)); do b="$b${1: i:4} "; done; echo $b | tr A-Z a-z; }

readKeys || die "Could not extract pairing keys"
token=$(formatToken $(makeToken))
[ ${#token} -eq 84 ] || die "Token $token has incorrect length"

echo "Writing $token to /dev/$DEV"
bccmd psload -s 0 /dev/stdin <<-EOF
// PSKEY_USR42
&02b4 = $token
// PSKEY_INITIAL_BOOTMODE
&03cd = 0002
EOF
bccmd psget 0x2b4
echo "Make sure the above output is $token"
