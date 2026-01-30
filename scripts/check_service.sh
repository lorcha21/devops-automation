#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  check_service.sh [-s SERVICE] [-l LOG_FILE] [--dry-run]

Options:
  -s SERVICE     Service systemd à vérifier (ex: ssh, sshd) (default: ssh)
  -l LOG_FILE    Fichier de log (default: ./service_check.log)
  --dry-run      N'effectue pas le restart, affiche seulement l'action
  -h, --help     Aide

Exit codes:
  0  OK (service running)
  1  KO (service down, restart tenté ou à tenter en dry-run)
  2  Service inconnu (systemd ne le reconnaît pas)
  3  Erreur d'usage
EOF
}

SERVICE="ssh"
LOG_FILE="./service_check.log"
DRY_RUN="false"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

log() {
  echo "$(timestamp) - $1" | tee -a "$LOG_FILE"
}

service_known() {
  systemctl status "$1" >/dev/null 2>&1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      [[ $# -lt 2 ]] && { echo "Missing value for -s"; usage; exit 3; }
      SERVICE="$2"; shift 2;;
    -l)
      [[ $# -lt 2 ]] && { echo "Missing value for -l"; usage; exit 3; }
      LOG_FILE="$2"; shift 2;;
    --dry-run)
      DRY_RUN="true"; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown option: $1"
      usage
      exit 3;;
  esac
done

# Fallback ssh -> sshd si ssh pas reconnu
if ! service_known "$SERVICE"; then
  if [[ "$SERVICE" == "ssh" ]] && service_known "sshd"; then
    SERVICE="sshd"
  else
    log "ERROR - service '$SERVICE' not recognized by systemd"
    exit 2
  fi
fi

if systemctl is-active --quiet "$SERVICE"; then
  log "OK - $SERVICE is running"
  exit 0
else
  if [[ "$DRY_RUN" == "true" ]]; then
    log "KO - $SERVICE is DOWN, would restart (dry-run)"
    exit 1
  fi

  log "KO - $SERVICE is DOWN, restarting..."
  sudo systemctl restart "$SERVICE"
  log "ACTION - $SERVICE restarted"
  exit 1
fi
