#!/bin/bash

echo "🔥 Genesis System Smoke Test Initiated..."

# 1. Ingest folder
if [ -d ~/genesis/ingest ]; then
  echo "✅ Ingest folder found."
else
  echo "❌ Ingest folder missing. Creating..."
  mkdir -p ~/genesis/ingest
fi

# 2. Git check for auto-push on feature branch
cd ~/genesis || exit
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" == "main" ]; then
  echo "⚠️  You're on main. Switch to a feature branch for safe push checks."
else
  echo "🔁 Git push test (dry-run):"
  git add .
  git commit -m "🔍 Smoke test $(date)" --allow-empty
  git push --dry-run origin "$BRANCH"
fi

# 3. Supabase sync check
if command -v supabase &> /dev/null; then
  echo "🔍 Supabase CLI found. Checking health..."
  supabase status
else
  echo "❌ Supabase CLI not installed."
fi

# 4. Memory mirror
if [ -L ~/genesis/memory_link ]; then
  echo "✅ memory_link is a valid symlink."
else
  echo "❌ memory_link is broken or missing."
fi

# 5. Picky Bot commit audit
echo "🤖 PickyBot Audit"
FILES=$(git diff --name-only origin/main)
for file in $FILES; do
  if [[ "$file" == *.py || "$file" == *.sh ]]; then
    echo "📂 Checking $file"
    if grep -q "TODO\\|FIXME" "$file"; then
      echo "⚠️  Warning: $file contains TODO or FIXME"
    fi
  fi
done

echo "🩺 Smoke test completed."
