import base64
import json
import os
import subprocess
import time
import uuid

import requests
import runpod


def start_comfyui_server():
    """Start the ComfyUI server"""
    print("Starting ComfyUI server...")
    process = subprocess.Popen(
        ['python3', '/app/ComfyUI/main.py', '--listen', '0.0.0.0', '--port', '8188'],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT
    )

    # Wait for server to be ready
    max_attempts = 30
    for i in range(max_attempts):
        try:
            response = requests.get('http://localhost:8188', timeout=2)
            if response.status_code == 200:
                print("ComfyUI server is ready!")
                return process
        except requests.RequestException:
            pass
        time.sleep(2)

    process.terminate()
    raise Exception("ComfyUI server failed to start")


# Start the server when module loads
comfyui_process = start_comfyui_server()


def queue_workflow(workflow):
    """Queue a workflow in ComfyUI"""
    payload = {
        "prompt": workflow,
        "client_id": str(uuid.uuid4())
    }
    response = requests.post("http://localhost:8188/prompt", json=payload)
    if response.status_code != 200:
        raise Exception(f"Failed to queue workflow: {response.text}")
    return response.json()


def wait_for_completion(prompt_id, timeout=300):
    """Wait for workflow completion and get results"""
    start_time = time.time()
    while time.time() - start_time < timeout:
        response = requests.get(f"http://localhost:8188/history/{prompt_id}")
        if response.status_code == 200:
            history = response.json()
            if prompt_id in history and 'outputs' in history[prompt_id]:
                return history[prompt_id]['outputs']
        time.sleep(1)
    raise Exception(f"Workflow timed out after {timeout} seconds")


def get_images_from_outputs(outputs):
    """Extract images from workflow outputs"""
    images = []
    for node_id, node_output in outputs.items():
        if 'images' in node_output:
            for image_info in node_output['images']:
                filename = image_info['filename']
                subfolder = image_info.get('subfolder', '')
                
                image_path = f"/app/ComfyUI/output/{subfolder}/{filename}" if subfolder else f"/app/ComfyUI/output/{filename}"
                
                if os.path.exists(image_path):
                    with open(image_path, 'rb') as f:
                        image_data = base64.b64encode(f.read()).decode('utf-8')
                        images.append({'filename': filename, 'data': image_data})
    return images


def handler(event):
    """
    Expected input:
    {
        "input": {
            "workflow": { ... }
        }
    }
    """
    try:
        workflow = event.get("input", {}).get("workflow")
        
        if not workflow:
            raise ValueError("Missing 'workflow' in input")
        
        print("Queueing workflow...")
        queue_response = queue_workflow(workflow)
        prompt_id = queue_response['prompt_id']
        
        print(f"Waiting for completion (prompt_id: {prompt_id})...")
        outputs = wait_for_completion(prompt_id, timeout=300)
        
        print("Extracting images...")
        images = get_images_from_outputs(outputs)
        
        return {
            "status": "success",
            "images": images
        }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"error": str(e), "status": "failed"}


if __name__ == "__main__":
    print("Starting RunPod handler...")
    runpod.serverless.start({"handler": handler})