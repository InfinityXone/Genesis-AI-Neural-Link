#!/bin/bash

GENESIS_HOME=~/genesis

echo "🔧 Initializing Genesis System at $GENESIS_HOME"
cd "$GENESIS_HOME" || exit 1

# Ensure required directories exist
mkdir -p .github/workflows
mkdir -p sql/migrations
mkdir -p scripts/logs
mkdir -p modules
mkdir -p agents
mkdir -p memory
mkdir -p infrastructure

# Touch key operational files
touch scripts/check_env.sh scripts/setup_env.sh
chmod +x scripts/*.sh

echo "✅ Directory structure initialized."

# Display final structure (optional: install tree if not available)
if command -v tree &> /dev/null; then
  tree -L 2
else
  find . -type d | sort
fi

echo -e "\\n🚀 Next Steps:"
echo "  1. Populate scripts/check_env.sh and scripts/setup_env.sh"
echo "  2. Run: chmod +x scripts/genesis_bootstrap.sh"
echo "  3. Launch this script again anytime for reset"
