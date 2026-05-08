#!/bin/sh
# Teltonika Tor WAN Guard installer
# Run from the repository root on the router.

set -eu

REPO_DIR="$(pwd)"
CONF_SRC="$REPO_DIR/config/torblock.conf"
FW_SRC="$REPO_DIR/config/firewall.user.example"
UPDATE_SRC="$REPO_DIR/scripts/update_tor_blocklist.sh"
VALIDATE_SRC="$REPO_DIR/scripts/validate_torblock.sh"

if [ ! -f "$CONF_SRC" ] || [ ! -f "$FW_SRC" ] || [ ! -f "$UPDATE_SRC" ]; then
    echo "ERROR: Run install.sh from the repository root."
    exit 1
fi

cp "$CONF_SRC" /etc/torblock.conf
cp "$UPDATE_SRC" /root/update_tor_blocklist.sh
cp "$VALIDATE_SRC" /root/validate_torblock.sh
chmod 700 /root/update_tor_blocklist.sh /root/validate_torblock.sh

# Backup existing firewall.user once per install run.
BACKUP="/etc/firewall.user.backup.$(date +%Y%m%d%H%M%S)"
cp /etc/firewall.user "$BACKUP" 2>/dev/null || true

echo "Backed up /etc/firewall.user to $BACKUP"

echo ""
echo "IMPORTANT: Review /etc/torblock.conf and confirm WAN_IFACE before continuing."
echo "Current setting:"
grep '^WAN_IFACE=' /etc/torblock.conf || true

echo ""
echo "Appending Tor WAN Guard block to /etc/firewall.user"
echo "" >> /etc/firewall.user
cat "$FW_SRC" >> /etc/firewall.user

/root/update_tor_blocklist.sh || true

# Install cron entry if absent.
CRON_LINE="17 */6 * * * /root/update_tor_blocklist.sh"
crontab -l 2>/dev/null | grep -v '/root/update_tor_blocklist.sh' > /tmp/torblock.cron || true
echo "$CRON_LINE" >> /tmp/torblock.cron
crontab /tmp/torblock.cron
rm -f /tmp/torblock.cron

/etc/init.d/cron enable 2>/dev/null || true
/etc/init.d/cron restart 2>/dev/null || true
/etc/init.d/firewall restart

echo "Install complete. Run: /root/validate_torblock.sh"
