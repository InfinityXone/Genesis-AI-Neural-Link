#!/bin/bash
# ===============================================================
# Infinity Loop Bridge — local <-> GPT /mnt/data sync layer
# ===============================================================
# Purpose:
#   Keeps ~/genesis and /mnt/data/genesis fully mirrored.
#   Performs integrity checks and recursive sync both ways.
# ===============================================================

set -euo pipefail

LOCAL_REPO="$HOME/genesis"
DATA_REPO="/mnt/data/genesis"
LOG_FILE="$LOCAL_REPO/logs/infinity_loop_bridge.log"

# --- Safety guard -------------------------------------------------------------
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --- Integrity check ----------------------------------------------------------
checksum() {
  find "$1" -type f -exec sha256sum {} + | sort -k 2 | sha256sum | cut -d' ' -f1
}

# --- Sync functions -----------------------------------------------------------
push_to_data() {
  log "🔁 Pushing local → /mnt/data..."
  rsync -a --delete "$LOCAL_REPO"/ "$DATA_REPO"/
  log "✅ Push complete."
}

pull_from_data() {
  log "🔁 Pulling /mnt/data → local..."
  rsync -a --delete "$DATA_REPO"/ "$LOCAL_REPO"/
  log "✅ Pull complete."
}

# --- Bridge loop --------------------------------------------------------------
log "🚀 Infinity Loop Bridge started."
PREV_LOCAL_HASH="$(checksum "$LOCAL_REPO")"
PREV_DATA_HASH="$(checksum "$DATA_REPO")"

while true; do
  sleep 30  # Adjust sync interval as needed

  LOCAL_HASH="$(checksum "$LOCAL_REPO")"
  DATA_HASH="$(checksum "$DATA_REPO")"

  if [[ "$LOCAL_HASH" != "$PREV_LOCAL_HASH" ]]; then
    push_to_data
    PREV_LOCAL_HASH="$LOCAL_HASH"
    PREV_DATA_HASH="$(checksum "$DATA_REPO")"
  elif [[ "$DATA_HASH" != "$PREV_DATA_HASH" ]]; then
    pull_from_data
    PREV_DATA_HASH="$DATA_HASH"
    PREV_LOCAL_HASH="$(checksum "$LOCAL_REPO")"
  else
    log "💤 No changes detected; bridge idle."
  fi
done
