# Hardening Notes

## Purpose

Tor exit-node blocking is useful for reducing anonymous inbound attack noise, but it is not a complete security strategy.

## Recommended companion controls

### Disable WAN administration

Where possible, disable WAN access to:

- Web UI
- SSH
- Telnet
- API services

Use VPN-only administration.

### Prefer WireGuard or IPsec for administration

Expose a minimal VPN listener rather than exposing management services directly.

### Minimise port forwards

Every port forward should have:

- Business owner
- Technical owner
- Purpose
- Review date
- Logging requirement
- Authentication requirement
- Patch owner

### Segment networks

Use separate zones/VLANs for:

- Admin
- Corporate LAN
- Penetration testing lab
- SDR/RF systems
- OT/ICS systems
- Guest/Wi-Fi
- IoT

### Centralise logs

Forward logs to syslog or SIEM where possible. Monitor:

- Repeated hits from Tor exits
- Authentication failures
- Scanning patterns
- Hits against unexpected ports
- Changes to firewall rules

### Use allow-listing for sensitive services

For high-value services, IP allow-listing is stronger than reputation-based blocking.

## Limitations

Blocking Tor exit nodes does not block:

- Commercial VPN providers
- Residential proxy networks
- Compromised hosts
- VPS/cloud attack infrastructure
- Botnets
- Misconfigured legitimate scanners

Treat this project as one layer in a defence-in-depth architecture.
