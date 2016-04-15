TextBlade Dongler
===

Set up test VM
---
1. Install Nix and VirtualBox
  * http://nixos.org/nix
  * http://virtualbox.org
1. Install NixOps
  * `nix-env -i nixops`
1. Deploy dongler VM
  * `nixops create -d dongler dongler-vm/*.nix`
  * `nixops deploy --force-reboot -d dongler`
1. Shut down VM and enable USB in VirtualBox settings
1. Start VM and attach USB dongle to VM
1. Log in and play with Bluez 5
  * `nixops ssh -d dongler dongler`
  * Easiest is to pair with `bluetoothctl`
    * `scan on`
    * `devices`
    * `pair <tab>`
    * `quit`

Available data
---
Once the device is paired, the `/var/lib/<dongle mac>/<TB mac>/info` file contains the following section:
```
[LongTermKey]
Key=CC12CF161FD6060A83038BE37BA508E1
Authenticated=0
EncSize=16
EDiv=37829
Rand=9287543943116976046
```
EncSize and Rand are decimal and have to be converted to hex, use `echo 'obase=16; 36829; 9287543943116976046' | bc` for that.

CRS8510 programming
---
The `PSKEY_USR42` field has to be set to `tbMac + 1482 + be16(EDiv) + be64(Rand) + be16(Key)` (all hexadecimal), where be16 and be64 are big-endian representations, 2 and 8 bytes long respectively. This means the Rand is reversed entirely and the Key on every 2 bytes

Once that is set, `bccmd psset -r -s 0 0x3cd 2` will set the dongle into USB keyboard mode.

Roadmap
---
* [x] Working VirtualBox with bluetooth
* [ ] Make working dongle
* [ ] Scripts to automate
* [ ] Nix package to compile program to switch dongle back into BT host mode
* [ ] livecd/liveusb image
