# Incident SSH – Simulation

## Détection
Le service SSH est passé à l'état `inactive`.
L'incident a été détecté automatiquement par un script exécuté via cron.

## Impact
Risque de perte d'accès distant à la machine.

## Cause
Arrêt manuel du service SSH (simulation).

## Action corrective
Redémarrage automatique du service via script Bash.

## Prévention
- Surveillance périodique via cron
- Logs horodatés
- Script avec codes de retour exploitables
