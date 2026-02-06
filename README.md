![CI](../../actions/workflows/docker-check.yml/badge.svg)
## Usage (Local)

Build nothing needed, just run:

```bash
./scripts/check_service.sh -s sshd --dry-run

# DevOps Automation

Ce dépôt contient des scripts d'automatisation orientés **Run / MCO**.
L'objectif est de fournir des outils simples, robustes et réutilisables pour
la supervision et la gestion de services Linux.

---

## 📁 Structure du projet


---

## 🔧 Script : check_service.sh

Script Bash permettant de :
- vérifier l'état d'un service systemd
- écrire des logs horodatés
- redémarrer automatiquement le service si nécessaire
- fonctionner en mode **dry-run**
- retourner des **codes de sortie** exploitables (cron, CI, monitoring)

---

## 🚀 Utilisation

### Vérifier un service
```bash
./scripts/check_service.sh -s ssh
