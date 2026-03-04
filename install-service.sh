#!/usr/bin/env bash
set -euo pipefail

UNIT_NAME="chromebook.service"
UNIT_PATH="/etc/systemd/system/${UNIT_NAME}"
TMP_UNIT="$(mktemp)"
UNIT_CONTENT='[Unit]
Description=Unload Chromebook EC drivers before suspend
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
ExecStart=/sbin/modprobe -r cros_ec_lpcs cros_ec_keyb cros_ec_typec || true
ExecStop=/sbin/modprobe cros_ec_lpcs || true
ExecStop=/sbin/modprobe cros_ec_keyb || true
ExecStop=/sbin/modprobe cros_ec_typec || true
RemainAfterExit=yes

[Install]
WantedBy=sleep.target
'

trap 'rm -f "$TMP_UNIT"' EXIT

printf "%s" "$UNIT_CONTENT" > "$TMP_UNIT"
mv "$TMP_UNIT" "$UNIT_PATH"
chmod 644 "$UNIT_PATH"

if systemctl daemon-reload && systemctl enable "$UNIT_NAME" && systemctl start "$UNIT_NAME"; then
  echo "done"
else
  echo "fail" >&2
  exit 1
fi

