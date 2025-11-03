#!/bin/bash
set -e

echo "🚀 Starting container initialization..."
echo "Current working directory: $(pwd)"
echo "Listing contents of /app and /workspace for debugging:"
ls -al /app || echo "⚠️ /app not found"
ls -al /workspace || echo "⚠️ /workspace not found"

# Possible ComfyUI locations
CANDIDATES=(
  "/app/ComfyUI"
  "/workspace/ComfyUI"
  "/opt/ComfyUI"
  "/mnt/ComfyUI"
)


COMFY_PATH=""

# Try to find the correct ComfyUI directory
for path in "${CANDIDATES[@]}"; do
  if [ -d "$path" ]; then
    COMFY_PATH="$path"
    echo "✅ Found ComfyUI directory at: $COMFY_PATH"
    break
  fi
done

# If not found, log error and exit
if [ -z "$COMFY_PATH" ]; then
  echo "❌ No ComfyUI directory found in known locations!"
  echo "📂 Directory tree of /app (if exists):"
  ls -R /app 2>/dev/null || true
  echo "📂 Directory tree of /workspace (if exists):"
  ls -R /workspace 2>/dev/null || true
  exit 1
fi

# Continue setup
cd "$COMFY_PATH"

mkdir -p models/checkpoints models/loras models/vae

echo "✅ Preloaded models:"
ls models/checkpoints || true

cd /workspace

echo "📢 Launching handler..."
python handler.py
