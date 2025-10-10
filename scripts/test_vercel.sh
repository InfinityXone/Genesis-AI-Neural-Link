#!/bin/bash
echo "📦 Vercel Sync Test"
if command -v vercel &>/dev/null; then
  vercel ls || echo "❌ vercel list failed"
else
  echo "❌ vercel missing"
fi
echo "✅ Vercel test done."
