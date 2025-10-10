#!/bin/bash
LOGTABLE="system_health"
OUT=\$(~/genesis/scripts/full_sync_test.sh 2>&1)
STATUS=\$?
if [ \$STATUS -ne 0 ] || echo "\$OUT" | grep -q "❌"; then
  echo "⚠️ Issues found, running recovery..."
  cd ~/genesis || exit 1
  git pull origin "\$(git rev-parse --abbrev-ref HEAD)" || true
  git push origin "\$(git rev-parse --abbrev-ref HEAD)" || true
  supabase db push || true
  vercel --prod || true
  gcloud run deploy --quiet || true
  echo "Recovery done"
else
  echo "✅ All systems healthy"
fi
