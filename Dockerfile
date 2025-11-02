FROM runpod/worker-comfyui:5.5.0-base

COPY ./start.sh /workspace/start.sh
COPY ./handler.py /workspace/handler.py
RUN chmod +x /workspace/start.sh

RUN comfy model download \
    --url "https://civitai.com/api/download/models/2255476?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
    --relative-path models/checkpoints \
    --filename cyberrealistic_pony.safetensors

CMD ["/workspace/start.sh"]
