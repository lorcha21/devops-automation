#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  check_service.sh [-s SERVICE_OR_PROCESS] [-l LOG_FILE] [--dry-run]

Modes:
  - Si systemd est disponible (VM/hôte): check via systemctl (service)
  - Si systemd n'est pas disponible (conteneur): check via pgrep (process)

Options:
  -s NAME        Nom du service (systemd) ou du process (container) (default: ssh)
  -l LOG_FILE    Fichier de log (default: ./service_check.log)
  --dry-run      N'effectue pas le restart, affiche seulement l'action
  -h, --help     Affiche l'aide

Exit codes:
  0  OK (running)
  1  KO (down) - restart tenté / simulé / impossible (container)
  2  Service/process inconnu
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

has_systemd() {
  [[ -d /run/systemd/system ]] && [[ "$(ps -p 1 -o comm= 2>/dev/null || true)" == "systemd" ]]
}

check_process() {
  # check if a process with exact name exists
  pgrep -x "$1" >/dev/null 2>&1
}

service_known() {
  if has_systemd; then
    [[ "$(systemctl show -p LoadState --value "$1" 2>/dev/null)" == "loaded" ]]
  else
    # In containers without systemd, "known" means we can at least check a process name.
    # We'll consider it "known" if the string is non-empty; existence is validated by is_running.
    [[ -n "${1:-}" ]]
  fi
}

is_running() {
  if has_systemd; then
    systemctl is-active --quiet "$1"
  else
    check_process "$1"
  fi
}

restart_service() {
  local name="$1"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "KO - $name is DOWN, would restart (dry-run)"
    return 1
  fi

  if has_systemd; then
    log "KO - $name is DOWN, restarting..."
    # If running as root, sudo is not needed. Keep it safe:
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      systemctl restart "$name"
    else
      sudo systemctl restart "$name"
    fi
    log "ACTION - $name restarted"
    return 1
  else
    log "KO - $name is DOWN, cannot restart without systemd (container mode)"
    return 1
  fi
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

# systemd mode fallback ssh -> sshd
if has_systemd; then
  if ! service_known "$SERVICE"; then
    if [[ "$SERVICE" == "ssh" ]] && service_known "sshd"; then
      SERVICE="sshd"
    else
      log "ERROR - service '$SERVICE' not recognized by systemd"
      exit 2
    fi
  fi
else
  # Container mode: ensure a process name is provided
  if ! service_known "$SERVICE"; then
    log "ERROR - process name is empty"
    exit 2
  fi
fi

if is_running "$SERVICE"; then
  log "OK - $SERVICE is running"
  exit 0
else
  # In container mode, if the process doesn't exist, we return KO (1)
  # In systemd mode, we attempt restart (or dry-run)
  restart_service "$SERVICE"
  exit 1
fi
