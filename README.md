# LLM MLC LLM AI AGENT on Qualcomm® Adreno™

**Version:** 1.0

**Release Date:** Sep 2025

**Copyright:** © 2025 Advantech Corporation. All rights reserved.

---

## Overview

**MLC LLM AI AGENT on Qualcomm® QCS6490™ Image** delivers an optimized, on-device AI inference solution designed for privacy-preserving, tool enabled & low-latency deployments at the edge. It leverages **MLC-compiled LLMs** and **OpenCL** acceleration to efficiently execute **Meta Llama 3.2 models 3B** directly on Qualcomm® QCS6490™ platforms. The container integrates a **FastAPI-based middleware** exposing an **OpenAI-compatible completions API** and the MLC TVM runtime for flexible compute distribution on GPU (OpenCL). Together with OpenWebUI for interactive chat experiences, it forms a complete local inference stack supporting **tool-augmented reasoning**, and **custom LLM workflows**. This container demonstrates how MLC LLM enables edge-native, high-performance generative AI deployments on Qualcomm® hardware.

---  

## Key Features

| Feature                                   | Description                                                                                                                                     |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| **MLC TVM Runtime**                       | Optimized compiler + runtime stack for running quantized models with GPU acceleration.                                                      |
| **OpenCL Support**                        | Runs LLM models on **Adreno GPU** |
| **QNN & SNPE Acceleration**                  | Added supports for execution of quantized `.bin` models on Hexagon DSP v68.                                                                               |
| **OpenWebUI**                             | Clean, browser-based interface for interactive chat.                                                                                            |
| **OpenAI-Compatible API**                 | REST API for `/chat/completions`, works with OpenWebUI, LangChain, etc.                                                                         |
| **Streaming Output**                      | Real-time token-by-token streaming in both CLI and API.                                                                                         |
| **AI Agent with EdgeSync Device Library** | Tool-enabled agent for interacting with edge peripherals (e.g., sensors, actuators) through natural language commands                           |
| **LangChain Integration**                 | Multi-turn memory with `ConversationChain` support                                                                                              |
| **Offline Deployment**                    | Fully offline after container setup and model copy.                                                                                             |
| **Flexible Parameters**                   | Supports parameters like `temperature`, `top_p`, `repetition_penalty`, `frequency_penalty`, `presence_penalty`, `max_num_tokens` |

---  

## Architecture

![Arch](./data/images/mlc-agent-arch.PNG)

---

## Hardware Specifications

| Component   | Specification                            |
|-------------|------------------------------------------|
| **Device**  | Advantech AOM-2721                       |
| **SoC**     | Qualcomm® QCS6490™ (soc_id-35)           |
| **GPU**     | Adreno™ 643 (OpenCL backend supported)   |
| **DSP/HTP** | Hexagon™ 770 v68 with tensor accelerator |
| **Memory**  | 8GB LPDDR5                               |

---

## Operating System

This container is intended for **QCOM Robotics Reference Distro with ROS**, version **1.3-ver.1.1** OS running on QCS6490 device.

| Environment     | OS                                                  |
|-----------------|-----------------------------------------------------|
| **Device Host** | QCOM Robotics Reference Distro with ROS 1.3-ver.1.1 |
| **Container**   | Ubuntu 22.04 LTS                                    |

---

## Software Components

| Component           | Version  | Description                                              |
|---------------------|----------|----------------------------------------------------------|
| **MLC LLM Runtime** | 0.1.dev0 | Provides TVM-compiled LLM runtime for GPU/HTP            |
| **Apache TVM**      | 0.14+    | Compiler stack used by MLC to generate optimized kernels |
| **QNN SDK**         | 2.32.0   | Qualcomm Neural Network runtime for quantized models     |
| **SNPE**            | 2.32.0   | Snapdragon Neural Processing Engine                      |

The following software components/packages are provided further as a part of this image:

| Component                                | Version     | Description                                                                     |
|------------------------------------------|-------------|---------------------------------------------------------------------------------|
| **Python**                               | 3.10.12     | For FastAPI + backend scripts                                                   |
| **LangChain**                            | 0.2.17      | Installed via PIP, framework to build LLM applications                          |
| **FastAPI**                              | 0.116.1     | REST API server for OpenAI-compatible endpoints                                 |
| **OpenWebUI**                            | 0.6.5       | Lightweight frontend for chat via separate container                                                   |
| **Uvicorn**                              | Latest      | ASGI server for FastAPI                                                         |
| **FAISS**                                | 1.8.0.post1 | Vector store backend for enabling RAG with efficient similarity search          |
| **EdgeSync Device Library**              | 1.0.1       | EdgeSync is provided as part of the container image for low-level edge hardware components interaction with the AI Agent |

---

## Supported AI Capabilities

### LLM Models

| Model | Format | Notes |
|-------|--------|-------|
| Meta Llama 3.2 1B | `.bin` | Converted with MLC TVM |
| Meta Llama 3.2 3B | `.bin` | Converted with MLC TVM |

> **Note:** This is a non-exhaustive list of supported models that have been tested. There would be more models compatible with MLC TVM on QCS6490, and users are encouraged to explore further.
---

## Supported Model Formats

| Runtime     | Format    |
|-------------|-----------|
| MLC Runtime | `.bin`    |
| QNN         | `.bin`    |
| SNPE        | `.dlc`    |

---

## Repository Structure

```
LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/
├── .env                                        # Environment configuration
├── Model_Conversion_Guide.md                   # Instructions for converting models with MLC-TVM
├── efficient-prompting-for-compact-models.md   # Craft better prompts for small and quantized language models
├── README.md                                   # Overview and quick start steps
├── build.sh                                    # Build script
├── docker-compose.yml                          # Docker Compose setup
├── start_service.sh                            # Script to start MLC LLM API Service                         
├── wise-bench.sh                               # Script to verify acceleration and software stack inside container
├── windows-git-setup.md                        # Steps to fix LF/CRLF issues on windows while copying to device
├── data                                        # Contains subfolders for assets like images, gifs etc.
└── langchain-agent-service/                    # Core LangChain Agent API service
    ├── mlc_app.py                              # Main LangChain-FastAPI app
    ├── llm_loader.py                           # LLM loader (Ollama, Llama, etc.)
    ├── requirements.txt                        # Python dependencies
    ├── agent_setup.py                          # Agent setup code
    ├── start_services.sh                       # Start script
    ├── edgesync_utils.py                       # Wrapper module for EdgeSync interactions
    └── tools.py                                # Defines tools
```

## Container Description

`build.sh` launches the following containers:

- **llm-mlc-llm-ai-agent-on-qualcomm-adreno** → Runs MLC runtime for hardware-accelerated inference using OpenCL.

- **openweb-ui-service** → Web UI for chat interactions.

### LLM-MLC-AI-Agent-on-Qualcomm-Adreno Container Highlights

This container delivers a ready deployment of **Meta Llama 3.2 3B** on
Qualcomm® QCS6490™ devices using the **MLC runtime**. Built on the **Apache TVM compiler** stack, it provides a fully optimized, hardware-accelerated environment supporting **OpenCL (GPU)** backends for efficient on-device
inference.
The container includes a FastAPI-based orchestration layer exposing an OpenAI-compatible API, and can be easily extended
with **LangChain** for **agent workflows**. Designed for offline, low-latency operation, it enables
privacy-preserving
and real-time retrieval-based reasoning at the edge.

| Feature                      | Description                                                                                                                                                        |
|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Local Inference Engine**   | The `mlc_cli_chat` tool is provided to run text-to-text inference on the compiled Llama 3.2 3B model. It accepts a user prompt and streams the generated response. |
| **Middleware Logic Engine**  | FastAPI-based LangChain server handles agent logic, tools, memory .                                                                                                |
| **Agent & Tool Support**     | Easily define and run LangChain agents with tool integration (e.g., search, calculator).                                                                           |
| **OpenAI API Compatibility** | FastAPI backend exposes an OpenAI-compatible `/chat/completions` endpoint; works seamlessly with OpenWebUI.                                                        |
| **Streaming Output Support** | Supports real-time token-by-token streaming for chat UIs and API responses.                                                                                        |
| **Edge Optimized**           | Runs MLC LLM models efficiently on **Adreno GPU (OpenCL)**|
| **Customizable Behavior**    | Configure runtime parameters (e.g., `temperature`, `top_k`, `top_p`, `seed`, `max-num-tokens`) in model config JSON.                                    |
| **Prompt Engineering**       | Supports structured prompts with system, user, and assistant roles.                                                                                                |
| **Offline-First**            | Works fully offline after model conversion and deployment; no cloud dependency.                                                                                    |
| **Developer Friendly**       | Simple CLI (`mlc_cli_chat`) and Dockerized setup for quick local experimentation.                                                                                  |
| **Easy Integration**         | Backend-ready for FastAPI, OpenWebUI, and custom applications.                                                                                                     |
| **AI Dev Environment**       | Provides a full hardware-accelerated containerized environment for on-device LLM deployment, development and testing.                                                          |

### OpenWebUI Highlights

OpenWebUI serves as a lightweight, responsive frontend for interacting with LLMs deployed locally on the Qualcomm®
QCS6490™ device. In this setup, it connects directly to the FastAPI wrapper for running the `mlc_llm chat` interface,
which exposes an OpenAI-compatible endpoint powered by the Meta Llama 3.2 3B model. Containerizing OpenWebUI ensures a
modular, browser-accessible deployment that delivers a seamless real-time chat experience without cloud dependency,
fully optimized for on-device edge inference.

| Feature                             | Description                                                    |
|-------------------------------------|----------------------------------------------------------------|
| **User-Friendly Interface**         | Sleek, chat-style UI for real-time interaction.                |
| **OpenAI-Compatible Backend**       | Works with MLC, OpenAI, and similar APIs with minimal setup. |
| **Container-Ready Design**          | Lightweight and optimized for edge or cloud deployments.       |
| **Streaming Support**               | Enables real-time response streaming for interactive UX.       |
| **Authentication & Access Control** | Basic user management for secure access.                       |
| **Offline Operation**               | Runs fully offline with local backends like Ollama.            |

---

## List of READMEs

| Module            | Link                                                  | Description                                                                |
|-------------------|-------------------------------------------------------|----------------------------------------------------------------------------|
| Quick Start       | [README](./README.md)                                 | Overview of the container image                                            |
| Model Conversion  | [README](./Model_Conversion_Guide.md) | Instructions for converting models with MLC-TVM                            |
| Prompt Guidelines | [README](./efficient-prompting-for-compact-models.md) | Guidelines to craft better prompts for small and quantized language models |
| Windows Git Line Ending Setup | [README](./windows-git-setup.md) | Steps to configure Git on Windows to handle LF/CRLF line endings correctly          |
| SCP Troubleshooting Guide | [README](./scp-troubleshooting-guide.md) | Guidelines for troubleshooting issues related to SCP file transfers |

## Model Information

| Item               | Value                                                              |
|--------------------|--------------------------------------------------------------------|
| **Source**         | MLC + TVM compiled `.bin` model (Meta Llama 3.2 3B)                |
| **Architecture**   | Llama 3.2 3B                                                       |
| **Quantization**   | q4f16_0 (4-bit integers with FP16 scaling, using layout variant 0) |
| **Parameters**     | ~3B                                                                |
| **Model size**     | ~2 GB                                                              |
| **Context length** | 131072                                                             |

---

## Before You Start
Make sure you have SUSI installed before using AI Agent tools. Refer to the below link for SUSI installation.
- [SUSI package](https://github.com/ADVANTECH-Corp/SUSI/tree/master/ReleasePackage/RISC/Standard/Linux/ROM/ROM-2820/Yocto%204.2/ARM64)
- [SUSI installation](https://ess-wiki.advantech.com.tw/view/SUSI#Installation)

## Quick Start Guide

> **Note:** Before starting this LLM container, ensure that no other LLM container is currently running or using the port specified in the .env file (e.g., 8000); otherwise, stop and remove the active container first. Only one LLM container should run at a time to prevent port conflicts.

### Clone the Repository (on your development machine)

> **Note for Windows Users:**  
> If you are using **Linux**, no changes are needed — LF line endings are used by default.  
> If you are on **Windows**, please follow the steps in [Windows Git Line Ending Setup](./windows-git-setup.md) before cloning to ensure scripts and configuration files work correctly on Device.

```bash
git clone https://github.com/Advantech-EdgeSync-Containers/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno.git
cd LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno
```

### Transfer the `LLM-MLC-AI-Agent-on-Qualcomm-Adreno` folder to QCS6490 device

If you cloned the repo on a **separate development machine**, use `scp` to transfer only the relevant folder (refer to [SCP Troubleshooting Guide](./scp-troubleshooting-guide.md) if any issues faced):

```bash
# From your development machine (Ubuntu or Windows PowerShell if SCP is installed)
scp -r .\LLM-MLC-AI-Agent-on-Qualcomm-Adreno\ <username>@<qcs6490-ip>:/home/<username>/
```

Replace:

* `<username>` – Login username on the QCS6490 board (e.g., `root`)
* `<qcs6490-ip>` – IP address of the QCS6490 board (e.g., `192.168.1.42`)

This will copy the folder to `/home/<username>/LLM-MLC-AI-Agent-on-Qualcomm-Adreno/`.

Then SSH into the Qualcomm® device:

```bash
ssh <username>@<qcs6490-ip>
cd ~/LLM-MLC-AI-Agent-on-Qualcomm-Adreno
```

### Model Preparation

**Mandatory Pre-requisite:** Before executing the `build.sh` script, ensure that the **Meta Llama 3.2 3B model** and its associated runtime library are available in the `/model` directory of your **QCS6490 device**.

This step is **mandatory** for successful container deployment and inference.

#### Model Setup Options

You have two options to ensure the model files are correctly placed on the target device:

1.  **Convert the Model Using MLC-TVM**
2.  **Copy a Pre-Converted Model**

#### Option 1 — Convert the Model Using MLC-TVM

If the model is not yet converted for the MLC framework:

* Follow the detailed steps in the [Model_Conversion_Guide](./Model_Conversion_Guide.md) to generate the MLC-compatible model package.
* Once conversion is complete, **transfer the generated files** to your **QCS6490 target** under the project folder.

#### Option 2 — Copy a Pre-Converted Model

If you already have the converted model (or use this link to download pre-converted meta llama 3.2 3B model - [Download Model](https://advantecho365.sharepoint.com/:f:/r/sites/ContainerProject-Nagarro/Shared%20Documents/Nagarro%20Development/Qualcomm%20MLC%20LLM%20Models/MLC_LLM_Llama3.2_3B?csf=1&web=1&e=peHSbi)):

1.  **Create the model directory** on the target device (`QCS6490`).

    ```bash
    # On the target device (QCS6490)
    mkdir -p /home/root/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model
    ```

2.  **Transfer both the model folder and the `.so` file** from your development machine using `scp`:

    ```bash
    # From your development machine
    scp -r Llama3.2_3B_model_params root@<target_ip>:/home/root/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model/
    scp llama3.2-3b-instruct-q4f16_0-adreno-iot.so root@<target_ip>:/home/root/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model/
    ```

### Installation

```bash
# Make the build script executable
chmod +x build.sh

# Launch the container
./build.sh
```

### AI Accelerator and Software Stack Verification (Optional)

#### Verify AI Accelerator and Software Stack Inside Docker Container

```bash
chmod +x wise-bench.sh
./wise-bench.sh
```

![qc-llm-wise-bench](%2Fdata%2Fimages%2Fqc-llm-wise-bench.png)

Wise-bench logs are saved in the `wise-bench.log` file under `/workspace`

### Run services

```bash
# Make the start service script executable
chmod +x start_services.sh
# Launch the start services
./start_services.sh
```

### Check Installation Status

Exit from the container and run following command to check the status of the containers:

```bash
docker ps
```

Allow some time for containers to become healthy.

### UI Access

Access OpenWebUI via any browser using the URL given below. Create an account and perform login:

```bash
http://localhost_or_QCS6490_IP:3000
```

### Quick Demonstration:

![MLC_Llama3.2_3B_openwebui_response_gif](%2Fdata%2Fgifs%2Fqc-mlc-openwebui-response.gif)

---

## Sample Prompts for Calling AI Agent Tools

| Tool Name               | Tool Function Name        | Description                                                          | Sample Prompt |
|-------------------------|-------------------------|----------------------------------------------------------------------|--------|
| Device Information Tool | device_info_tool        | Retrieve detailed motherboard and BIOS information                   | Get me device information |
| Device Voltage Tool     | device_voltage_tool    | Get real-time voltage readings from all onboard voltage sources      | Get me voltage details |
| Device Temperature Tool | device_temperature_tool | Fetch current temperature data from all onboard temperature sensors | Get me temperature information |
| Device Fan Tool         | device_fans_tool | Check real-time fan speed (RPM) readings for each onboard fan sensor | What’s the fan speed? |
| GPIO Pins Overview      | gpio_pins_overview | Get an overview of GPIO pins directions and logic levels             | Show me GPIO overview |
| Set GPIO Pin Tool       | gpio_set_tool | Set the output level of a GPIO pin                                   | Set GPIO pin GPIO5 to low  |
| Read GPIO Pin Tool      | gpio_read_tool | Read the input level of a GPIO pin                                   | Read GPIO pin GPIO3  |



## Model Parameters Customization

The **MLC runtime** supports fine-tuning of runtime parameters such
as `temperature`, `top-k`, `top-p`, `repetition_penalty`, `frequency_penalty`, `presence_penalty`, and maximum token
length.  
These parameters can be configured in the **mlc_chat_config.json** file or passed dynamically through the API request.

By customizing these values, you can optimize the model for a wide range of use cases—from **deterministic outputs** for
testing and reproducibility to **creative, diverse generations** for conversational AI.

Below is an example section from the `mlc_chat_config.json` file with tuned values for **better quality and reduced
repetition**:

```bash
},
  "vocab_size": 128256,
  "context_window_size": 131072,
  ...
  "temperature": 0.8,
  "top_p": 0.9,
  "repetition_penalty": 1.15,
  "frequency_penalty": 0.7,
  "presence_penalty": 0.5
  "tokenizer_files": [
    "tokenizer.json",
    "tokenizer_config.json"
  ],
  ...
````

## Prompt Guidelines

This [README](./efficient-prompting-for-compact-models.md) provides essential prompt guidelines to help you get accurate
and reliable outputs from small and quantized language models.

## MLC LLM Logs and Troubleshooting

### Log Files

The MLC LLM engine provides an option to enable event logging for requests, which can be useful for debugging and
monitoring. You can enable tracing with the `--enable-tracing` argument for more advanced logging user can enable this.
Currently we are logging api service logs in below files:

| Log File    | Description                                                   |
|-------------|---------------------------------------------------------------|
| uvicorn.pid | Provides process-id for the currently running uvicorn service |
| uvicorn.log | Provides uvicorn service logs                                 |

### Troubleshoot

Here are quick commands/instructions to troubleshoot issues with running a model using **`mlc llm`**  ,**`mlc_cli_chat`
**, *FastAPI*, *uvicorn* and *OpenWebUI*:

- View uvicorn service logs within the container
  ```bash
  tail -f uvicorn.log
  ```
- Make sure that you are in `mlc-venv` environment if not then use below command to activate the `mlc-venv`.
   ```bash
   conda activate mlc-venv
   ```
- Verify that the model and all its dependencies are available for `mlc llm`. Ensure the model is loaded correctly for
  execution using the `mlc`. Run the following command inside the Docker container.
  ```bash
  mlc_llm serve --help
  ```

- If MLC Model is not running then check the Environment Variables
  ```bash
  echo $MLC_MODEL_PATH
  echo $MODEL_LIB
  ```
  These should match with the following as per the converted model files path:
  ```bash
  MLC_MODEL_PATH=/workspace/model/Llama3.2_3B_model_params
  MODEL_LIB=/workspace/model/llama-3.2-3b-instruct-q4f16_0-adreno-iot.so
  ```
- Verify that the model directory contains all required files in the correct folder structure — such as the MLC Chat
  Config file, tokenizer configuration file, and the tokenizer JSON file. Below is a reference example of the files
  typically found inside the model folder.
   ```bash
   (mlc-venv) root@qcs6490aom2721a1:/workspace/model Llama3.2_3B_model_params# ls
   mlc-chat-config.json  params_shard_1.bin   params_shard_12.bin  params_shard_15.bin params_shard_18.bin  params_shard_20.bin
   params_shard_4.bin  params_shard_7.bin tokenizer.json ndarray-cache.json    params_shard_10.bin  params_shard_13.bin 
   params_shard_16.bin  params_shard_19.bin  params_shard_21.bin  params_shard_5.bin params_shard_8.bin  tokenizer_config.json
   params_shard_0.bin  params_shard_11.bin params_shard_14.bin  params_shard_17.bin  params_shard_2.bin params_shard_3.bin
   params_shard_6.bin  params_shard_9.bin
  ```

- If OpenWebUI chat is not returning a response, use the following `curl` command to test the API directly. If the
  response shows an error message (e.g., model file or lib missing or any other error), take the necessary action based
  on the error.
  ```bash
  curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "model": "/workspace/model/Llama3.2_3B_model_params",
        "messages": [
            {"role": "user", "content": "What is the capital of France?"}
        ],
       "stream": false
  }' \
  http://192.168.29.121:8000/v1/chat/completions
  ```

- Kill & restart services within container (check pid manually via `ps -eaf` or use pid stored in `uvicorn.pid`)
  ```bash
  kill $(cat uvicorn.pid)
  ./start_services.sh
  ```

  Confirm there is no service running using:
  ```bash
  ps -eaf
  ```

## MLC LLM CLI Inference Sample

Here's a simple CLI example for running inference using `mlc_cli_chat`. This command invokes the MLC LLM engine to
execute the **Meta Llama 3.2 3B** model using a specified model, library file and device (OpenCL) , followed by a
user-defined prompt.

Inside the container `/workspace/mlc-llm/build/apps/mlc_cli_chat/`

```bash
./mlc_cli_chat --model /workspace/model/Llama3.2_3B_model_params/ --model-lib /workspace/model/llama3.2-3b-instruct-q4f16_0-adreno-iot.so --device  opencl --with-prompt  "What is the capital of France"
```

sample output:

![mlc_cli_chat_response](%2Fdata%2Fimages%2Fmlc_cli_chat_response.png)

this command will invoke a `mlc cli chat` application using `OpenCL` for `GPU` backend and provide user and chat
interface for inference.
For more details user can run below command:

```bash
./mlc_cli_chat --help
``` 

sample output:

![mlc_cli_chat_help](%2Fdata%2Fimages%2Fmlc_cli_chat_help.png)

user can also check the model inference stats using the `/stats` in the mlc cli chat terminal

---

## Best Practices and Recommendations

### Memory Management & Speed (MLC LLM on QCS6490)

- **Model Placement**: Ensure models are fully loaded into the DSP/HTP memory or GPU VRAM for optimal inference
  performance.
- **Batch Inference**: Use batch inference when running multiple requests to improve throughput efficiency.
- **Dynamic Memory Offloading**: Offload unused models from DSP/HTP/GPU memory when not needed to free up resources for
  active workloads.
- **Quantization Preference**: Prefer quantized models (e.g., **INT8, Q4F16**) to balance **speed, memory usage, and
  accuracy**.
- **Context Length Tuning**: Reduce the maximum context length when possible to minimize  memory usage without
  impacting task quality.
- **Token Management**: override  `max_tokens` in API payloads or `--max-tokens` in CLI runs to avoid unnecessarily long
  generations that increase latency and memory consumption.
- **Model Size Guidance**: For best performance on **QCS6490**, use models with **≤3B parameters**.

## REST API Access

If you’ve launched the **FastAPI backend** inside the container (`./start_services.sh`), you can call it with `curl`:

Inference Request:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "model": "/workspace/model/Llama3.2_3B_model_params",
        "messages": [
            {"role": "user", "content": "What is the capital of France?"}
        ],
       "stream": false
  }' \
  http://192.168.29.121:8000/v1/chat/completions
`````

Here stream mode could be changed as true/false as per the needs.

Response:

```bash
{"id":"chatcmpl-c36344de9e30405f814bb6bc71cf4b6b","choices":[{"finish_reason":"stop","index":0,"message":{"content":"The capital of France is Paris.","role":"assistant","name":null,"tool_calls":null,"tool_call_id":null},"logprobs":null}],"created":1758198358,"model":"/workspace/model/Llama3.2_3B_model_params","system_fingerprint":"","object":"chat.completion","usage":{"prompt_tokens":32,"completion_tokens":8,"total_tokens":40,"extra":null}}
```

Sample Screenshot:

![qc_mlc_api_response.png](%2Fdata%2Fimages%2Fqc_mlc_api_response.png)

---

### LangChain Middleware Tuning

- Use asynchronous chains and streaming response handlers to reduce latency in FastAPI endpoints.
- Avoid long chain dependencies; break workflows into smaller composable components.
- Cache prompt templates and tool results when applicable to reduce unnecessary recomputation
- For agent-based flows, limit tool calls per loop to avoid runaway execution or high memory usage.
- Log intermediate steps (using LangChain’s callbacks) for better debugging and observability
- Use models with ≥3B parameters (e.g., Llama 3.2 3B or larger) for agent development to ensure better reasoning depth
  and tool usage reliability.

## Known Limitations

1. **OpenWebUI Dependencies**  
   On the first startup, OpenWebUI installs certain dependencies. These are persisted in the associated Docker volume,
   so allow some time for this **one-time setup** to complete before use.

2. **Model Compilation**  
   Models must be explicitly converted for execution. Always verify the **quantization format** and **device
   compatibility (GPU / DSP / HTP)** before running a model.

3. **Model Size Restrictions**  
   Models larger than **3B parameters** may not run efficiently on QCS6490 due to memory constraints. GPU
   execution is possible but may suffer from latency or thermal throttling.

4. **Context Length Limitations**  
   Very long context lengths can exceed memory limits, leading to errors or performance degradation.
   Adjust `max_tokens` and context size accordingly.

5. **Docker Storage Constraints**  
   Running inside Docker containers can quickly consume disk space due to model weights, logs, and cache. Ensure
   sufficient storage is available on the device.

6. **Streaming Support**  
   While streaming improves responsiveness, it can cause higher memory pressure if multiple clients are connected
   simultaneously.


---

Copyright © 2025 Advantech Corporation. All rights reserved.
