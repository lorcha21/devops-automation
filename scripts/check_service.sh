#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-ssh}"

HOST="$(hostname)"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

LOG_FILE="${LOG_FILE:-./service_check.log}"

log() {
  echo "$(timestamp) - $1" | tee -a "$LOG_FILE"
}

# Vérifie si systemd connaît ce service (même si c'est un alias)
service_known() {
  systemctl status "$1" >/dev/null 2>&1
}

# Fallback ssh -> sshd si ssh n'est pas reconnu
if ! service_known "$SERVICE"; then
  if [[ "$SERVICE" == "ssh" ]] && service_known "sshd"; then
    SERVICE="sshd"
  else
    log "ERROR - service '$SERVICE' not recognized by systemd"
    exit 2
  fi
fi

if systemctl is-active --quiet "$SERVICE"; then
  log "$HOST - OK - $SERVICE is running"
else
  log "$HOST - KO - $SERVICE is DOWN, restarting..."
  sudo systemctl restart "$SERVICE"
  log "$HOST - ACTION - $SERVICE restarted"
fi
#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-ssh}"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

LOG_FILE="${LOG_FILE:-./service_check.log}"

log() {
  echo "$(timestamp) - $1" | tee -a "$LOG_FILE"
}

service_exists() {
  systemctl list-unit-files --type=service --no-legend \
    | awk '{print $1}' \
    | grep -qx "${1}.service"
}

# Auto-fallback: ssh -> sshd
if ! service_exists "$SERVICE"; then
  if [[ "$SERVICE" == "ssh" ]] && service_exists "sshd"; then
    SERVICE="sshd"
  else
    log "ERROR - ${SERVICE}.service not found (check with: systemctl list-unit-files --type=service | grep -i ssh)"
    exit 2
  fi
fi

if systemctl is-active --quiet "$SERVICE"; then
  log "$HOST - OK - $SERVICE is running"
else
  log "$HOST - KO - $SERVICE is DOWN, restarting..."
  sudo systemctl restart "$SERVICE"
  log "$HOST - ACTION - $SERVICE restarted"
fi

