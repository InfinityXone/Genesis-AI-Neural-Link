#!/bin/bash
echo "====== Full Sync Test ======"
~/genesis/scripts/test_supabase.sh
~/genesis/scripts/test_github.sh
~/genesis/scripts/test_gcloud.sh
~/genesis/scripts/test_vercel.sh
echo "====== Sync Test End ======"
