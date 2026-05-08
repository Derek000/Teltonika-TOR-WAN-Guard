# Testing Guide

## Test objectives

Confirm that:

1. The Tor exit-node list is populated.
2. WAN-origin new connections from Tor exits are dropped.
3. LAN-origin outbound Tor still works.
4. Existing/related return traffic is not broken.
5. Port-forwarded services are protected.

## Local router validation

```sh
/root/validate_torblock.sh
```

Expected:

- `tor_exit` ipset exists.
- Entry count is non-zero.
- INPUT and FORWARD rules reference the set.
- Recent logs show update activity.

## LAN-origin Tor validation

From a LAN host using Tor Browser, visit the Tor Project check page and confirm Tor is working.

This confirms the control is not blocking outbound LAN-origin Tor.

## Inbound validation

From an external test system using Tor, attempt to connect to a WAN-exposed service:

```sh
curl -v https://your-public-service.example
nc -vz your-public-ip 443
```

Expected result: connection fails or times out.

## Non-Tor inbound validation

From a normal external IP that should be permitted, test the same service.

Expected result: service behaves according to your normal firewall policy.

## Port-forward validation

If using DNAT/port forwarding, test both:

- Tor-origin external connection should fail.
- Approved non-Tor external connection should behave according to policy.

## Safety note

Do not perform unsolicited testing against third-party systems. Use only approved targets and authorised infrastructure.
