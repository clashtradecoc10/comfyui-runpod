#!/bin/bash
set -e

echo "🚀 Starting container initialization..."

COMFY_PATH="/comfyui"

if [ ! -d "$COMFY_PATH" ]; then
    echo "❌ ComfyUI not found at $COMFY_PATH"
    echo "📂 Checking alternative locations..."
    ls -la / | grep -i comfy || true
    exit 1
fi

echo "✅ Found ComfyUI at: $COMFY_PATH"
cd "$COMFY_PATH"

echo "✅ Available models:"
ls -lh models/checkpoints/ 2>/dev/null || echo "⚠️ No checkpoints directory found"

echo "📢 Starting ComfyUI server and handler..."
cd /workspace
python handler.py