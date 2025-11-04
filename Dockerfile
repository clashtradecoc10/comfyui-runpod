FROM runpod/worker-comfyui:5.5.0-base

RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/loras \
             /comfyui/models/vae

COPY ./start.sh /workspace/start.sh
COPY ./handler.py /workspace/handler.py
RUN chmod +x /workspace/start.sh

RUN comfy model download \
    --set-civitai-api-token 78df56f2a1a427ea3d1fd3076122d429 \
    --url "https://civitai.com/api/download/models/2334591?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
    --relative-path models/checkpoints \
    --filename cyberrealistic_pony.safetensors

CMD ["/workspace/start.sh"]
