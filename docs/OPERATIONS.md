# Operations Guide

## Routine checks

Weekly or before critical remote work:

```sh
/root/validate_torblock.sh
logread | grep torblock | tail -20
ipset list tor_exit | awk '/Number of entries/ {print}'
```

## Manual update

```sh
/root/update_tor_blocklist.sh
```

## Firewall reload

```sh
/etc/init.d/firewall restart
```

## Cron schedule

Default cron schedule:

```cron
17 */6 * * * /root/update_tor_blocklist.sh
```

This refreshes the Tor exit list every six hours.

## Change control recommendation

For professional or client environments, document:

- Router hostname and model
- RutOS version
- WAN interface name
- Date enabled
- Services protected
- Rollback method
- Validation evidence
- Known exceptions

## Logging improvement

The default rules silently drop packets. For short diagnostic windows, consider adding a limited logging rule before the drop rule:

```sh
iptables -I INPUT 2 -i "$WAN_IFACE" -m set --match-set "$IPSET_NAME" src \
  -m conntrack --ctstate NEW -m limit --limit 5/min --limit-burst 10 \
  -j LOG --log-prefix "TORBLOCK_INPUT "
```

Avoid permanent high-volume logging on small routers unless logs are forwarded and rate-limited.
