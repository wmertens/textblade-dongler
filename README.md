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

In theory these steps also work on Windows.


Roadmap
---
* [ ] Working VirtualBox with bluetooth
* [ ] Make working dongle
* [ ] Scripts to automate
* [ ] livecd/liveusb image
