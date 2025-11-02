#!/bin/bash
set -e

cd /workspace/ComfyUI

mkdir -p models/checkpoints models/loras models/vae

echo "✅ Preloaded models:"
ls models/checkpoints || true

cd /workspace
python handler.py
