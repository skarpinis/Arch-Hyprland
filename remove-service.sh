#!/usr/bin/env bash
set -euo pipefail

UNIT_NAME="chromebook.service"
UNIT_PATH="/etc/systemd/system/${UNIT_NAME}"

# Prompt for sudo
if ! sudo -v; then
echo "fail" >&2
exit 1
fi

# Stop and disable the unit (ignore errors if not present)
sudo systemctl stop "$UNIT_NAME" >/dev/null 2>&1 || true
sudo systemctl disable "$UNIT_NAME" >/dev/null 2>&1 || true

# Remove unit file if it exists
if sudo test -f "$UNIT_PATH"; then
if ! sudo rm -f "$UNIT_PATH"; then
echo "fail" >&2
exit 1
fi
fi

# Reload systemd to apply changes
if sudo systemctl daemon-reload; then
echo "done"
else
echo "fail" >&2
exit 1
fi
