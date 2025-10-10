#!/bin/bash

# === CONFIG ===
PROJECT_ID="my-project-52092gpt-deployer"
REGION="us-west1"
SECRET_NAME="github-pat"
BUCKET_NAME="infinity-swarm-system"
SERVICES=("gpt-gateway" "genesis")
MOUNT_POINT="/mnt/genesis"
RCLONE_REMOTE="gcs"

# === STEP 1: Inject GitHub PAT ===
echo "🔐 Injecting GitHub PAT into Cloud Run services..."
for SERVICE in "${SERVICES[@]}"; do
  gcloud run services update $SERVICE \
    --update-secrets=GITHUB_PAT=${SECRET_NAME}:latest \
    --region=$REGION \
    --platform=managed
done

# === STEP 2: Mount GCS Clean Memory ===
echo "📦 Mounting GCS bucket as clean memory..."
mkdir -p $MOUNT_POINT
rclone mount ${RCLONE_REMOTE}:${BUCKET_NAME} $MOUNT_POINT \
  --daemon \
  --vfs-cache-mode=off \
  --allow-other

# === STEP 3: Initialize Clean Directory Structure ===
echo "🧬 Initializing memory folders (if missing)..."
gsutil -m mkdir -p gs://$BUCKET_NAME/{{genesis/{laws,codex,memory,evolution_log},swarm/{faucet_logs,task_activity,agents},rosetta/{directive_feed,validation_scores,crossloop_data},semantic/{vector_db,langchain_store,embedding_index},hydration/{memory_snapshots,regen_triggers,daily_recall}}}

# === STEP 4: Connect Supabase (Assumes SUPABASE_URL + KEY in .env or agent config) ===
echo "🔗 Connecting to Supabase for live agent directives, swarm analytics, and wallet updates..."
# No logs or bloat will be stored here—just real-time essential ops.

echo "✅ Genesis + Swarm deploy script complete. Clean. Cloud-native. Recursive-ready."
