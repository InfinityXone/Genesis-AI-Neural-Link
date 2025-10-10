#!/bin/bash
echo "🔐 Genesis Environment Audit Starting..."

ENV_FILE="$HOME/config/production.env"
REQUIRED_VARS=(
  SUPABASE_URL SUPABASE_SERVICE_ROLE_KEY SUPABASE_ANON_KEY
  VERCEL_ORG_ID VERCEL_PROJECT_ID VERCEL_TOKEN
  GCP_PROJECT_ID GCP_SA_KEY
  OPENAI_API_KEY GROQ_API_KEY
)

echo "📄 Checking env file presence: $ENV_FILE"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Missing env file!"
  exit 1
else
  echo "✅ Env file found"
fi

echo "🔍 Validating required variables..."
MISSING=0
for VAR in "${REQUIRED_VARS[@]}"; do
  grep -q "^export $VAR=" "$ENV_FILE" || {
    echo "⚠️ Missing variable: $VAR"
    MISSING=$((MISSING + 1))
  }
done

if [ "$MISSING" -gt 0 ]; then
  echo "❌ Some required variables are missing. Fix before continuing."
  exit 2
else
  echo "✅ All required variables present"
fi

echo "🧪 Testing environment in shell context..."
source "$ENV_FILE"
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo "⚠️ Variable exists in file but not loaded in shell: $VAR"
  else
    echo "✅ $VAR loaded"
  fi
done

echo "🔄 Checking for extraneous secrets in Git history..."
git rev-list --all | xargs git grep -F "SUPABASE_SERVICE_ROLE_KEY" && {
  echo "⚠️ Secret appears in Git history!"
}

echo "📋 Checking cloud deployment parity..."

# Example: check Vercel env via CLI
if command -v vercel &> /dev/null; then
  echo "📦 Listing Vercel env:"
  vercel env ls
else
  echo "⚠️ Vercel CLI not installed"
fi

# GCP: describe Run service to see env
if command -v gcloud &> /dev/null; then
  echo "☁️ Inspecting GCP Run env for service gpt-gateway:"
  gcloud run services describe gpt-gateway --region us-west1 --format "flattened(env)"
else
  echo "⚠️ gcloud CLI not installed"
fi

echo "✅ Env audit complete."
