cat > README.md <<'EOF'
![CI](../../actions/workflows/docker-check.yml/badge.svg)

# DevOps Automation — Service Health Check

A small Bash tool to check if a service/process is running, log the result, and optionally restart it (systemd only).

This project is designed to work in both environments:
- **Host/VM mode** (systemd available)
- **Container mode** (no systemd)

---

## Features

- Check a service status (systemd mode)
- Check a process presence (container mode)
- Timestamped logs
- Dry-run mode
- Works in Docker
- CI validated with GitHub Actions
- Makefile helpers

---

## Repository structure

```text
scripts/
  check_service.sh
.github/workflows/
  docker-check.yml
Dockerfile
Makefile
README.md
