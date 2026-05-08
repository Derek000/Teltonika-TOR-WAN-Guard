# Installation Guide

## Purpose

Install Teltonika Tor WAN Guard so that new inbound WAN traffic from Tor exit nodes is dropped before it reaches router services or port-forwarded internal services.

## Pre-installation checks

1. Confirm you have SSH access to the Teltonika.
2. Confirm you have a rollback path, preferably local console, LAN access, or out-of-band management.
3. Confirm the WAN interface name:

```sh
ifstatus wan
ip route
ip addr
```

4. Confirm these commands exist:

```sh
which iptables
which ipset
which wget
which crontab
```

If `ipset` is missing, install or enable the relevant RutOS/OpenWRT package before continuing.

## Installation

Copy the repository to the router, then run:

```sh
chmod +x scripts/*.sh
vi config/torblock.conf
./scripts/install.sh
```

Edit `WAN_IFACE` in `config/torblock.conf` if your WAN interface is not `wan`.

## Post-installation validation

```sh
/root/validate_torblock.sh
ipset list tor_exit | head
iptables -L INPUT -n -v --line-numbers | head -30
iptables -L FORWARD -n -v --line-numbers | head -30
```

From a LAN host, confirm Tor Browser still works. The controls should not block LAN-origin Tor because only NEW inbound traffic arriving on the WAN interface is dropped.

## Rollback

```sh
/root/uninstall.sh
/etc/init.d/firewall restart
```

Also inspect `/etc/firewall.user` and remove the appended Tor WAN Guard block if needed.
