#!/bin/bash
echo "☁️ Google Cloud Sync Test"
if command -v gcloud &>/dev/null; then
  gcloud run services list --region us-west1 || echo "❌ list services failed"
else
  echo "❌ gcloud missing"
fi
echo "✅ Google Cloud test done."
