# Contributing

Contributions are welcome where they improve defensive reliability, clarity, safety, or Teltonika/RutOS compatibility.

## Preferred contributions

- RutOS model compatibility notes
- nftables variants for newer platforms
- IPv6 support patterns
- Safer installer improvements
- Validation enhancements
- Documentation improvements

## Requirements

- Keep scripts POSIX `sh` compatible where possible.
- Avoid dependencies that are unlikely to exist on small routers.
- Prefer safe failure behaviour.
- Avoid flushing live firewall policy unexpectedly.
- Preserve LAN-to-WAN outbound Tor support.
