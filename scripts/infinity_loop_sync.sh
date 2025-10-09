#!/bin/bash
# ==========================================================
# Genesis :: Infinity Loop Sync — Continuous Bridge Runner
# ==========================================================

GENESIS_LOCAL="$HOME/genesis"
GENESIS_BRIDGE="/mnt/data/genesis"
LOGFILE="$GENESIS_LOCAL/logs/infinity_loop.log"
INTERVAL=60  # seconds between syncs

echo "[$(date)] 🌌 Infinity Loop Sync initialized..." | tee -a "$LOGFILE"

while true; do
  echo "[$(date)] 🔄 Checking sync state..." | tee -a "$LOGFILE"

  # 1️⃣ Sync local → bridge
  rsync -av --delete "$GENESIS_LOCAL/" "$GENESIS_BRIDGE/" --exclude '.git' >> "$LOGFILE" 2>&1

  # 2️⃣ Commit & push local → GitHub
  cd "$GENESIS_LOCAL" || exit
  if [[ -n $(git status --porcelain) ]]; then
    echo "[$(date)] 🚀 Changes detected — committing and pushing..." | tee -a "$LOGFILE"
    git add .
    git commit -m "🧠 Auto-sync from Infinity Loop $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main >> "$LOGFILE" 2>&1
  else
    echo "[$(date)] 💤 No new changes." | tee -a "$LOGFILE"
  fi

  # 3️⃣ Verify Supabase ping (optional)
  curl -s "$SUPABASE_URL/rest/v1/system_health" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -o /dev/null && echo "[$(date)] ✅ Supabase health OK." | tee -a "$LOGFILE"

  echo "[$(date)] 🌊 Loop complete. Sleeping for $INTERVAL seconds..." | tee -a "$LOGFILE"
  sleep "$INTERVAL"
done
