#!/usr/bin/env bash
set -euo pipefail

# Prompt for sudo password once
if ! sudo -v; then
  echo "fail" >&2
  exit 1
fi

UNIT_NAME="chromebook.service"
UNIT_PATH="/etc/systemd/system/${UNIT_NAME}"
TMP_UNIT="$(mktemp)"
UNIT_CONTENT='[Unit]
Description=Unload Chromebook EC drivers before suspend
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
ExecStart=/sbin/modprobe -r cros_ec_lpcs cros_ec_keyb cros_ec_typec
ExecStop=/sbin/modprobe cros_ec_lpcs
ExecStop=/sbin/modprobe cros_ec_keyb
ExecStop=/sbin/modprobe cros_ec_typec
RemainAfterExit=yes

[Install]
WantedBy=sleep.target
'

trap 'rm -f "$TMP_UNIT"' EXIT

printf "%s" "$UNIT_CONTENT" > "$TMP_UNIT"

# Use sudo to move and set permissions
if ! sudo mv "$TMP_UNIT" "$UNIT_PATH"; then
  echo "fail" >&2
  exit 1
fi
if ! sudo chmod 644 "$UNIT_PATH"; then
  echo "fail" >&2
  exit 1
fi

if sudo systemctl daemon-reload && sudo systemctl enable "$UNIT_NAME" && sudo systemctl start "$UNIT_NAME"; then
  echo "done"
else
  echo "fail" >&2
  exit 1
fi

