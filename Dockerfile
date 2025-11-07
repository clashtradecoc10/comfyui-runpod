FROM runpod/worker-comfyui:5.5.0-base

# Create all necessary directories
RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/loras \
             /comfyui/models/vae \
             /comfyui/models/upscale_models \
             /comfyui/models/ultralytics/bbox \
             /comfyui/custom_nodes

# Copy your scripts
COPY ./start.sh /workspace/start.sh
COPY ./handler.py /workspace/handler.py
RUN chmod +x /workspace/start.sh

# Copy your local model data
COPY comfyui/loras/ /comfyui/models/loras/
COPY comfyui/upscale_models/ /comfyui/models/upscale_models/
COPY comfyui/ultralytics/bbox/ /comfyui/models/ultralytics/bbox/

# 🧠 Download your base checkpoint
RUN comfy model download \
    --set-civitai-api-token 78df56f2a1a427ea3d1fd3076122d429 \
    --url "https://civitai.com/api/download/models/2334591?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
    --relative-path models/checkpoints \
    --filename cyberrealistic_pony.safetensors

# 🧩 Install ComfyUI Impact Pack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack /comfyui/custom_nodes/ComfyUI-Impact-Pack && \
    pip install -r /comfyui/custom_nodes/ComfyUI-Impact-Pack/requirements.txt

# 🧩 Install ComfyUI Impact Subpack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack /comfyui/custom_nodes/ComfyUI-Impact-Subpack && \
    pip install -r /comfyui/custom_nodes/ComfyUI-Impact-Subpack/requirements.txt

# 🧩 Install ComfyUI GlifNodes
RUN git clone https://github.com/glifxyz/ComfyUI-GlifNodes.git /comfyui/custom_nodes/ComfyUI-GlifNodes && \
    pip install -r /comfyui/custom_nodes/ComfyUI-GlifNodes/requirements.txt

# Cleanup to keep image small
RUN rm -rf /root/.cache/pip

# Start ComfyUI
CMD ["/workspace/start.sh"]
