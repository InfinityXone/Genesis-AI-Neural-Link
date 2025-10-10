#!/bin/bash

LOG_DIR="$HOME/genesis/logs"
INGEST_DIR="$HOME/genesis/ingest"
ARCHIVE_DIR="$HOME/genesis/archives"
TIMESTAMP=$(date "+%Y-%m-%d-%H%M%S")

echo "🧼 Genesis Cleaner initializing..."

# 1. Clean old logs (older than 2 days)
find "$LOG_DIR" -type f -mtime +2 -exec rm -v {} \;

# 2. Sort ingest folder
mkdir -p "$ARCHIVE_DIR"
for file in "$INGEST_DIR"/*; do
  if [ -f "$file" ]; then
    EXT="${file##*.}"
    TARGET="$ARCHIVE_DIR/$EXT"
    mkdir -p "$TARGET"
    mv "$file" "$TARGET/" && echo "📦 Moved $file → $TARGET"
  fi
done

# 3. Check broken symlinks
echo "🔗 Checking symlinks..."
find "$HOME/genesis" -type l ! -exec test -e {} \; -print

echo "✅ Cleanup complete. Snapshot taken at $TIMESTAMP"
