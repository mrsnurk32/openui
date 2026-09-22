#!/usr/bin/env bash
set -euo pipefail

# Pull Qwen models into the Ollama container.
# Override with: MODELS="qwen2.5:7b qwen2.5-coder:7b" ./scripts/pull-qwen.sh

MODELS="${MODELS:-qwen2.5:7b qwen2.5-coder:7b}"

if ! docker compose ps ollama --status running >/dev/null 2>&1; then
  echo "Ollama is not running. Start the stack first: docker compose up -d"
  exit 1
fi

for model in $MODELS; do
  echo "Pulling $model ..."
  docker compose exec ollama ollama pull "$model"
done

echo "Done. Models should appear in Open WebUI shortly."
