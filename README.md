# Teltonika Tor WAN Guard

Dynamic WAN-only Tor exit-node blocking for Teltonika RutOS / OpenWRT-derived routers.

This project provides a lightweight, auditable way to protect **WAN-exposed router services and port-forwarded services** from new inbound traffic originating from Tor exit nodes, while preserving legitimate **LAN-to-WAN outbound Tor usage** for OSINT, penetration testing, research, and privacy-preserving activity.

## Why this exists

Many commercial, Defence-adjacent, OT, RF, cyber range, and remote-site deployments use Teltonika routers as compact perimeter devices. These systems often expose limited services such as VPN, SSH, HTTPS admin portals, telemetry collectors, reverse tunnels, or port-forwarded lab services.

Blocking all Tor traffic is usually too blunt for professional cyber teams because Tor may be required for authorised OSINT and testing. This project applies a safer model:

```text
ALLOW: LAN -> WAN outbound connections, including Tor
ALLOW: Established/related return traffic
DROP:  NEW inbound WAN traffic from known Tor exit nodes
```

## What it protects

- Teltonika router WAN-facing services
- VPN listeners exposed on WAN
- Port-forwarded services behind the router
- Lab, SDR, OT, or cyber-range services reachable via WAN NAT

## What it does not block

- LAN users accessing Tor Browser
- LAN-origin OSINT activity
- LAN-origin authorised commercial penetration testing
- Return traffic for LAN-initiated sessions

## Supported environments

Designed for Teltonika RutOS / OpenWRT-derived devices that support:

- `iptables`
- `ipset`
- `cron`
- `wget`
- `/etc/firewall.user`

Common candidate devices include RUTX, RUT, TRB, and related industrial Teltonika routers. Interface names differ by model and WAN type, so validate before deployment.

## Repository layout

```text
.
├── config/
│   ├── firewall.user.example
│   └── torblock.conf
├── docs/
│   ├── ARCHITECTURE.md
│   ├── HARDENING.md
│   ├── INSTALL.md
│   ├── OPERATIONS.md
│   ├── TESTING.md
│   └── TROUBLESHOOTING.md
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   ├── update_tor_blocklist.sh
│   └── validate_torblock.sh
├── tests/
│   └── shellcheck_notes.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
└── SECURITY.md
```

## Quick start

1. Copy the repository to your Teltonika router or upload only the `scripts/` and `config/` files.
2. SSH to the router.
3. Confirm the WAN interface name:

```sh
ifstatus wan
ip route
ip addr
```

4. Edit `config/torblock.conf` if your WAN interface is not `wan`.
5. Run:

```sh
chmod +x scripts/*.sh
./scripts/install.sh
```

6. Validate:

```sh
/root/validate_torblock.sh
ipset list tor_exit | head
iptables -L INPUT -n -v --line-numbers | head -30
iptables -L FORWARD -n -v --line-numbers | head -30
```

## Default behaviour

The default configuration assumes your WAN interface is named `wan` and creates these firewall behaviours:

```sh
iptables -I INPUT 2 -i wan -m set --match-set tor_exit src -m conntrack --ctstate NEW -j DROP
iptables -I FORWARD 2 -i wan -m set --match-set tor_exit src -m conntrack --ctstate NEW -j DROP
```

The `--ctstate NEW` condition is important. It avoids breaking established return traffic for LAN-origin sessions.

## Safety warning

Do not deploy blindly to a remote router without out-of-band access. A typo in firewall configuration can lock you out.

Before production use:

- Confirm WAN interface name
- Confirm router management is not exposed unnecessarily
- Confirm VPN access still works
- Confirm port forwards behave as expected
- Confirm LAN-to-WAN OSINT traffic is unaffected
- Keep a rollback path available

## Recommended security posture

This project is a control for reducing anonymous inbound attack noise. It should not be treated as a complete perimeter security strategy.

Recommended companion controls:

- Disable WAN router admin access
- Use WireGuard or IPsec for administration
- Apply MFA where supported upstream
- Minimise port forwards
- Use allow-listing for sensitive services
- Send logs to a central syslog/SIEM
- Segment LAN, admin, lab, OT, SDR, and guest networks
- Monitor for scanning, brute force, and exposed-service abuse

## Licence

MIT. Use at your own risk.
