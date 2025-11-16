#!/usr/bin/env bash
set -euo pipefail


# collect.sh
# Collect logs and describe for the first pod matching label app=bad-app


OUTDIR="$(dirname "$0")"
OUTFILE="$OUTDIR/output.txt"


POD="$(kubectl get pods -l app=bad-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"


if [ -z "$POD" ]; then
echo "No pod found with label app=bad-app. Make sure you've applied kubernetes/bad-deployment.yaml"
exit 1
fi


echo "Collecting logs and describe for pod: $POD"


echo "----- METADATA -----" > "$OUTFILE"
kubectl get pod "$POD" -o yaml >> "$OUTFILE" 2>&1 || true


echo "\n----- LOGS -----" >> "$OUTFILE"
kubectl logs "$POD" >> "$OUTFILE" 2>&1 || true


echo "\n----- DESCRIBE -----" >> "$OUTFILE"
kubectl describe pod "$POD" >> "$OUTFILE" 2>&1 || true


echo "Logs and describe written to $OUTFILE"
