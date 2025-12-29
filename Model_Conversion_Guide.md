# MLC Model Conversion Guide (Host x86 → Meta LLaMA 3.2 3B)

**Version:** 1.0  
**Release Date:** Aug 2025  
**Copyright:** © 2025 Advantech Corporation. All rights reserved.  

## Overview
This document describes the end-to-end process for setting up the host environment on **x86-64**, compiling **MLC-LLM**, converting the **Meta-LLaMA 3.2 3B** model, and preparing artifacts for deployment on target devices.

---

## 1. Host Setup (x86-64) - Ubuntu 22.04

  

### 1.1 Install Conda & cmake

```bash

sudo apt update

sudo apt install cmake -y

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh

```
  

### 1.2 Install Python and Dependencies

```bash

source ~/.bashrc  # Launch anaconda environment

conda create -n  mlc-venv  -c  conda-forge  "llvmdev=15"  "cmake"  git  numpy  decorator  psutil  typing_extensions cython scipy  attrs  git-lfs  gcc=10.4  gxx=10.4  python=3.10

conda activate  mlc-venv

```
### 1.3 Install Rust (Version 1.80)

Rust is required for compiling parts of **MLC-LLM**. Install via `rustup`

```bash
# Install rustup and Rust 1.80.1

curl --proto  '=https'  --tlsv1.2  -sSf  https://sh.rustup.rs | sh  -s  --  -y

~/.cargo/bin/rustup install 1.80.1

~/.cargo/bin/rustup default 1.80.1

 
# (Optional) Cleanup caches

rm -rf  ~/.cargo/registry  ~/.cargo/git

export PATH=$HOME/.cargo/bin:$PATH

```

**Verify Rust installation:**

```bash

rustc --version
cargo --version

```
Expected output:

refer the below screenshot

![version_screenshot](%2Fdata%2Fimages%2Fqc-model-convert-version.png)


### 1.4 Compile MLC Package

```bash

git clone --recursive  https://github.com/CodeLinaro/mlc-llm.git

cd mlc-llm

mkdir build && cd  build

python ../cmake/gen_cmake_config.py  # Select opencl and openclhostptr = y else n refer below screenshot

```
![screenshot](%2Fdata%2Fimages%2Fqc-model-convert-screenshot.png)

```
/usr/bin/cmake  ..

make -j16

cd ..

```


### 1.5 Compile TVM Package

```bash

mkdir -p  ./3rdparty/tvm/build

cd 3rdparty/tvm/build

cp ../cmake/config.cmake  .

  
# Enable required options

echo 'set(USE_OPENCL ON)' >> config.cmake

echo 'set(USE_OPENCL_ENABLE_HOST_PTR ON)' >> config.cmake

echo 'set(USE_LLVM ON)' >> config.cmake
  

/usr/bin/cmake ..

make -j16

cd ../../../

```

  

### 1.6 Install MLC + TVM Python Packages

```bash

cd 3rdparty/tvm/python

pip install  -e  .

cd ../../../
  
cd python

sed -i  's/CONDA_BUILD = os.getenv("CONDA_BUILD") is not None/CONDA_BUILD = True/'  setup.py

pip install  -e  .

cd ..

```

  

### 1.7 Verify Installation

```bash

python -c "import mlc_llm; print(mlc_llm.__path__)"

python -c "import mlc_llm; print(mlc_llm.__version__)"

```

  
---

## 2. Model Compilation (Meta-LLaMA 3.2 3B)
  

### 2.1 Download Model (Use Hugging Face Access Tokens as a Password)

```bash

git clone https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct

cd Llama-3.2-3B-Instruct

git lfs install

git lfs pull

cd ..

```

  

### 2.2 Export Cross-Compiler (if targeting ARM)

```bash

sudo apt install gcc-aarch64-linux-gnu

export TVM_NDK_CC=/usr/bin/aarch64-linux-gnu-gcc

```

  

### 2.3 Generate Model Weights & Config

```bash

python -m  mlc_llm gen_config Llama-3.2-3B-Instruct --quantization q4f16_0 --conv-template llama-3 --prefill-chunk-size 256 -o Llama3.2_3B_model_params

```

  

### 2.4 Convert Model Weights

```bash

python -m mlc_llm convert_weight Llama-3.2-3B-Instruct/ --quantization q4f16_0 -o Llama3.2_3B_model_params --device llvm

```

  

### 2.5 Compile Model Library

```bash

python -m  mlc_llm compile Llama3.2_3B_model_params/mlc-chat-config.json --quantization q4f16_0 --device android:adreno-so -o llama3.2-3b-instruct-q4f16_0-adreno-iot.so

```

---

  

## 3. Deploy Artifacts

  
On Host:

```bash

scp -r Llama3.2_3B_model_params root@<target_ip>:/home/root/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model/

scp llama3.2-3b-instruct-q4f16_0-adreno-iot.so root@<target_ip>:/home/root/LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model/

```


On Target (RB3/QCS6490):

```bash

mkdir -p LLM-MLC-LLM-AI-Agent-on-Qualcomm-Adreno/model

```


---

  

## 4. Run Model

  

On target device (inside container or natively):

```bash

cd mlc-llm/build/apps/mlc_cli_chat/

./mlc_cli_chat --model /workspace/model/Llama3.2_3B_model_params/ --model-lib /workspace/model/llama3.2-3b-instruct-q4f16_0-adreno-iot.so --device  opencl

```  

---
  

## 5. Key Notes

- Replace device type (`llvm`, `opencl`, `android:adreno-so`) depending on deployment target.

- Quantization `q4f16_0` provides a balance of accuracy and performance.

- Ensure Hugging Face access token is configured if the Meta-LLaMA repo requires authentication.

- For debugging, use:

```bash

./mlc_cli_chat --help

```

## 6. Uninstallation / Cleanup  

To remove installed tools, environments, and models if no longer needed:  

### 6.1 Remove Conda Environment  
```bash
conda deactivate
conda remove -n mlc-venv --all -y
```

### 6.2 Remove Rust and Cargo  
```bash
rm -rf ~/.cargo ~/.rustup
```

### 6.3 Remove MLC-LLM and TVM Source  
```bash
rm -rf mlc-llm
```

### 6.4 Remove Model Artifacts  
```bash
rm -rf model/Llama-3.2-3B-Instruct llama3_model_params llama3.2-3b-instruct-q4f16_0-adreno-iot.so 
```

### 6.5 Optional: Clean Conda Installation  
```bash
rm -rf ~/miniconda3 ~/.conda
```

---

This will restore the system to a clean state (before installing MLC + Rust + LLaMA model).

