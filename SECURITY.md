# Security Policy

## Supported use

This project is intended for defensive network administration and authorised security operations.

## Reporting issues

If you identify a security flaw in the scripts or configuration approach, open a private advisory or issue in your GitHub repository and include:

- Affected script or document
- RutOS/OpenWRT version if relevant
- Reproduction steps
- Expected behaviour
- Actual behaviour
- Suggested mitigation if known

## Security assumptions

- The router administrator is authorised to modify firewall rules.
- The router has a working rollback path.
- `ipset`, `iptables`, `wget`, and `cron` are available.
- WAN interface names are validated before deployment.

## Scope exclusions

This project does not claim to block all anonymity networks, VPNs, residential proxies, compromised hosts, VPS infrastructure, or botnets.
