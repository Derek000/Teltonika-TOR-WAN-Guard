#!/bin/sh
# Teltonika Tor WAN Guard - Tor exit-node ipset updater
# Maintains an ipset of Tor exit nodes without flushing the production set until a valid replacement exists.

CONF_FILE="/etc/torblock.conf"
[ -f "$CONF_FILE" ] && . "$CONF_FILE"

IPSET_NAME="${IPSET_NAME:-tor_exit}"
TOR_URL="${TOR_URL:-https://check.torproject.org/torbulkexitlist}"
IPSET_MAXELEM="${IPSET_MAXELEM:-65536}"
TMP_FILE="/tmp/tor_exit_nodes.txt"
CLEAN_FILE="/tmp/tor_exit_nodes.clean"
LOCK_FILE="/tmp/update_tor_blocklist.lock"
NEW_SET="${IPSET_NAME}_new"

log() {
    logger -t torblock "$1"
    echo "$1"
}

cleanup() {
    rm -f "$TMP_FILE" "$CLEAN_FILE" "$LOCK_FILE"
}

if [ -f "$LOCK_FILE" ]; then
    log "Update already running; exiting."
    exit 0
fi

touch "$LOCK_FILE"
trap cleanup EXIT

log "Starting Tor exit-node update."

if ! command -v ipset >/dev/null 2>&1; then
    log "ERROR: ipset not found. Install/enable ipset support first."
    exit 1
fi

if ! command -v wget >/dev/null 2>&1; then
    log "ERROR: wget not found."
    exit 1
fi

ipset create "$IPSET_NAME" hash:ip family inet maxelem "$IPSET_MAXELEM" -exist

wget -q -O "$TMP_FILE" "$TOR_URL"
if [ $? -ne 0 ] || [ ! -s "$TMP_FILE" ]; then
    log "ERROR: Failed to download Tor exit list or list was empty. Existing ipset retained."
    exit 1
fi

# Keep IPv4 addresses only. Teltonika/RutOS IPv6 support varies by model/configuration.
grep -E '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' "$TMP_FILE" | sort -u > "$CLEAN_FILE"

if [ ! -s "$CLEAN_FILE" ]; then
    log "ERROR: Downloaded list contained no valid IPv4 entries. Existing ipset retained."
    exit 1
fi

ipset create "$NEW_SET" hash:ip family inet maxelem "$IPSET_MAXELEM" -exist
ipset flush "$NEW_SET"

while read IP; do
    ipset add "$NEW_SET" "$IP" -exist
done < "$CLEAN_FILE"

ipset swap "$NEW_SET" "$IPSET_NAME"
ipset destroy "$NEW_SET" 2>/dev/null

COUNT="$(ipset list "$IPSET_NAME" 2>/dev/null | awk '/Number of entries/ {print $4}')"
log "Tor exit-node update complete. Entries loaded: ${COUNT:-unknown}."
