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
