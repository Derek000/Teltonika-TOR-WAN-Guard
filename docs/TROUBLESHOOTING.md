# Troubleshooting

## LAN Tor access stopped working

Check whether you accidentally added a broad FORWARD rule without WAN interface scoping.

Bad pattern:

```sh
iptables -I FORWARD -m set --match-set tor_exit src -j DROP
```

Correct pattern:

```sh
iptables -I FORWARD -i "$WAN_IFACE" -m set --match-set tor_exit src -m conntrack --ctstate NEW -j DROP
```

## Rules are not matching

Confirm the WAN interface name:

```sh
ip addr
ip route
ifstatus wan
```

Update `/etc/torblock.conf` and restart firewall.

## ipset is empty

Run:

```sh
/root/update_tor_blocklist.sh
logread | grep torblock | tail -20
```

Check router DNS, WAN connectivity, and TLS interception/proxy constraints.

## Firewall restart fails

Check syntax:

```sh
sh -n /etc/firewall.user
```

Restore the backup created by the installer:

```sh
cp /etc/firewall.user.backup.YYYYMMDDHHMMSS /etc/firewall.user
/etc/init.d/firewall restart
```

## Router locked out

Use local LAN, console, serial, failsafe mode, or out-of-band access. For remote production routers, always stage and validate changes before relying on them.
