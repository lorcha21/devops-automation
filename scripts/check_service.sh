#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-ssh}"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

service_exists() {
  systemctl list-unit-files --type=service --no-legend \
    | awk '{print $1}' \
    | grep -qx "${1}.service"
}

# Auto-fallback: ssh -> sshd si ssh n'existe pas
if ! service_exists "$SERVICE"; then
  if [[ "$SERVICE" == "ssh" ]] && service_exists "sshd"; then
    SERVICE="sshd"
  else
    echo "$(timestamp) - ERROR - ${SERVICE}.service not found (check name with: systemctl list-unit-files --type=service | grep ssh)"
    exit 2
  fi
fi

if systemctl is-active --quiet "$SERVICE"; then
  echo "$(timestamp) - OK - $SERVICE is running"
else
  echo "$(timestamp) - KO - $SERVICE is DOWN, restarting..."
  sudo systemctl restart "$SERVICE"
  echo "$(timestamp) - ACTION - $SERVICE restarted"
fi

