#!/bin/bash
# Super Install Script: Sync / Watchdog / SelfHeal / Fallback

echo "🛠️ Installing Genesis Sync & Watchdog System..."

# Ensure scripts directory
mkdir -p ~/genesis/scripts
cd ~/genesis/scripts || exit 1

# 1. test_supabase.sh
cat << 'EOF' > test_supabase.sh
#!/bin/bash
echo "🔍 Supabase Sync Test..."
if command -v supabase &>/dev/null; then
  supabase status || echo "❌ Supabase status failed"
else
  echo "❌ Supabase CLI missing"
fi
if [ -n "\$SUPABASE_URL" ]; then
  curl -I "\$SUPABASE_URL" 2>/dev/null | head -n 1 || echo "❌ Supabase URL ping failed"
fi
echo "✅ Supabase test done."
EOF

# 2. test_github.sh
cat << 'EOF' > test_github.sh
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
EOF

# 3. test_gcloud.sh
cat << 'EOF' > test_gcloud.sh
#!/bin/bash
echo "☁️ Google Cloud Sync Test"
if command -v gcloud &>/dev/null; then
  gcloud run services list --region us-west1 || echo "❌ list services failed"
else
  echo "❌ gcloud missing"
fi
echo "✅ Google Cloud test done."
EOF

# 4. test_vercel.sh
cat << 'EOF' > test_vercel.sh
#!/bin/bash
echo "📦 Vercel Sync Test"
if command -v vercel &>/dev/null; then
  vercel ls || echo "❌ vercel list failed"
else
  echo "❌ vercel missing"
fi
echo "✅ Vercel test done."
EOF

# 5. full_sync_test.sh
cat << 'EOF' > full_sync_test.sh
#!/bin/bash
echo "====== Full Sync Test ======"
~/genesis/scripts/test_supabase.sh
~/genesis/scripts/test_github.sh
~/genesis/scripts/test_gcloud.sh
~/genesis/scripts/test_vercel.sh
echo "====== Sync Test End ======"
EOF

# 6. genesis_watchdog.sh
cat << 'EOF' > genesis_watchdog.sh
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
EOF

# Make all scripts executable
chmod +x test_supabase.sh test_github.sh test_gcloud.sh test_vercel.sh full_sync_test.sh genesis_watchdog.sh

# 7. Setup crontab entries (run watchdog every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/genesis/scripts/genesis_watchdog.sh >> ~/genesis/logs/rsync/watchdog.log 2>&1") | crontab -

# 8. Setup systemd user service for watchdog (auto start on login)
mkdir -p ~/.config/systemd/user
cat << 'EOF' > ~/.config/systemd/user/genesis-watchdog.service
[Unit]
Description=Genesis Watchdog Service
After=network.target

[Service]
ExecStart=/home/$USER/genesis/scripts/genesis_watchdog.sh
Restart=on-failure
WorkingDirectory=/home/$USER

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable genesis-watchdog
systemctl --user start genesis-watchdog

echo "✅ Sync & Watchdog System Installed. Running initial test..."
~/genesis/scripts/full_sync_test.sh
