#!/bin/sh
# Teltonika Tor WAN Guard uninstaller

CONF_FILE="/etc/torblock.conf"
[ -f "$CONF_FILE" ] && . "$CONF_FILE"

IPSET_NAME="${IPSET_NAME:-tor_exit}"
WAN_IFACE="${WAN_IFACE:-wan}"

iptables -D INPUT   -i "$WAN_IFACE" -m set --match-set "$IPSET_NAME" src -m conntrack --ctstate NEW -j DROP 2>/dev/null || true
iptables -D FORWARD -i "$WAN_IFACE" -m set --match-set "$IPSET_NAME" src -m conntrack --ctstate NEW -j DROP 2>/dev/null || true

crontab -l 2>/dev/null | grep -v '/root/update_tor_blocklist.sh' > /tmp/torblock.cron || true
crontab /tmp/torblock.cron 2>/dev/null || true
rm -f /tmp/torblock.cron

ipset destroy "$IPSET_NAME" 2>/dev/null || true

rm -f /root/update_tor_blocklist.sh /root/validate_torblock.sh /etc/torblock.conf

echo "Uninstall complete. Manually remove the appended Tor WAN Guard block from /etc/firewall.user if required, then restart firewall."
