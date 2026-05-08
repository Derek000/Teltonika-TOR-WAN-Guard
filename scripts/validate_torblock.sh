#!/bin/sh
# Teltonika Tor WAN Guard validation helper

CONF_FILE="/etc/torblock.conf"
[ -f "$CONF_FILE" ] && . "$CONF_FILE"

IPSET_NAME="${IPSET_NAME:-tor_exit}"
WAN_IFACE="${WAN_IFACE:-wan}"

echo "== Teltonika Tor WAN Guard validation =="
echo "Config file: $CONF_FILE"
echo "IPSet:      $IPSET_NAME"
echo "WAN iface:  $WAN_IFACE"
echo ""

echo "== Interface check =="
ip addr show "$WAN_IFACE" 2>/dev/null || echo "WARNING: Interface $WAN_IFACE not found by ip addr. Confirm actual WAN interface."
echo ""

echo "== IPSet check =="
ipset list "$IPSET_NAME" 2>/dev/null | awk '/Name:|Number of entries/ {print}' || echo "ERROR: ipset $IPSET_NAME missing."
echo ""

echo "== Firewall INPUT Tor rules =="
iptables -L INPUT -n -v --line-numbers | grep -E "$IPSET_NAME|Chain|num" || true
echo ""

echo "== Firewall FORWARD Tor rules =="
iptables -L FORWARD -n -v --line-numbers | grep -E "$IPSET_NAME|Chain|num" || true
echo ""

echo "== Recent logs =="
logread 2>/dev/null | grep torblock | tail -20 || echo "No torblock log entries found."
echo ""

echo "Validation complete. Confirm LAN-origin Tor Browser still works from a LAN host."
