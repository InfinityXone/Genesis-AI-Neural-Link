#!/bin/bash
echo "🔄 GitHub Sync Test"
cd ~/genesis || { echo "❌ genesis missing"; exit 1; }
git fetch origin || { echo "❌ git fetch failed"; exit 1; }
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse origin/$(git rev-parse --abbrev-ref HEAD))
BASE=$(git merge-base @ origin/$(git rev-parse --abbrev-ref HEAD))
if [ "\$LOCAL" = "\$REMOTE" ]; then
  echo "✅ Up to date"
elif [ "\$LOCAL" = "\$BASE" ]; then
  echo "🔁 Pulling..."
  git pull origin "$(git rev-parse --abbrev-ref HEAD)"
elif [ "\$REMOTE" = "\$BASE" ]; then
  echo "🔼 Pushing..."
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
else
  echo "⚠️ Diverged"
fi
echo "✅ GitHub test done."
