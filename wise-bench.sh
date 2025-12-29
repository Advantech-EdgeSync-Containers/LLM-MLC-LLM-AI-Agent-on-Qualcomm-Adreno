#!/bin/bash



# Created by Samir Singh <samir.singh@advantech.com>

# Copyright (c) 2025 Advantech Corporation



# This script is a wrapper that runs the encoded entrypoint script

# The encoding protects the implementation details while allowing execution



# Clear the terminal

clear


LOG_FILE="/workspace/wise-bench.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Append timestamp to start of each run
{
  echo "==========================================================="
  echo ">>> Diagnostic Run Started at: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "==========================================================="
} >> "$LOG_FILE"


# Save original stdout and stderr
exec 3>&1 4>&2

# Redirect stdout & stderr to both console and file (append mode)
exec > >(tee -a "$LOG_FILE") 2>&1

# Simplified script with minimal formatting to avoid ANSI code issues



# Display banner

GREEN='\033[0;32m'

RED='\033[0;31m'

YELLOW='\033[0;33m'

BLUE='\033[0;34m'

CYAN='\033[0;36m'

BOLD='\033[1m'

PURPLE='\033[0;35m'

NC='\033[0m' # No Color



# Display fancy banner

echo -e "${BLUE}${BOLD}+------------------------------------------------------+${NC}"

echo -e "${BLUE}${BOLD}|    ${PURPLE}Advantech_COE Qualcomm® Hardware Diagnostics Tool${BLUE}    |${NC}"

echo -e "${BLUE}${BOLD}+------------------------------------------------------+${NC}"

echo
# Show Advantech COE ASCII logo - with COE integrated

echo -e "${BLUE}"

echo "       █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗███████╗ ██████╗██╗  ██╗     ██████╗ ██████╗ ███████╗"

echo "      ██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██╔════╝██╔════╝██║  ██║    ██╔════╝██╔═══██╗██╔════╝"

echo "      ███████║██║  ██║██║   ██║███████║██╔██╗ ██║   ██║   █████╗  ██║     ███████║    ██║     ██║   ██║█████╗  "

echo "      ██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║   ██║   ██╔══╝  ██║     ██╔══██║    ██║     ██║   ██║██╔══╝  "

echo "      ██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║   ██║   ███████╗╚██████╗██║  ██║    ╚██████╗╚██████╔╝███████╗"

echo "      ╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚══════╝"

echo -e "${WHITE}                                  Center of Excellence${NC}"

echo
echo -e "${YELLOW}${BOLD}▶ Starting hardware acceleration tests...${NC}"

echo

# Helper functions

print_header() {

    echo

    echo "+--- $1 ----$(printf '%*s' $((47 - ${#1})) | tr ' ' '-')+"

    echo "|$(printf '%*s' 50 | tr ' ' ' ')|"

    echo "+--------------------------------------------------+"

}



print_success() {

    echo "? $1"

}



print_warning() {

    echo "? $1"

}



print_info() {

    echo "? $1"

}



print_table_header() {

    echo "+--------------------------------------------------+"

    echo "| $1$(printf '%*s' $((47 - ${#1})) | tr ' ' ' ')|"

    echo "+--------------------------------------------------+"

}

print_summary_table_row() {
    local component="$1"
    local version="$2"
    local status="$3"
    printf "| %-22s | %-10s | %-13s |\n" "$component" "$version" "$status"
}

print_table_row() {
  if [ $# -eq 3 ]; then
    printf "| %-25s | %s | %s |\n" "$1" "$2" "$3"
  elif [ $# -eq 2 ]; then
    printf "| %-25s | %s |\n" "$1" "$2"
  else
    printf "| %-25s | %s |\n" "$1" "$2"
  fi
}


print_table_footer() {

    echo "+--------------------------------------------------+"

}



echo "? Setting up hardware acceleration environment..."



# -- Add trap to kill and wait for any background jobs on script exit --
trap 'jobs -p | xargs -r kill 2>/dev/null; wait 2>/dev/null' EXIT INT TERM


# System Information in a fancy tabular format

print_header "SYSTEM INFORMATION"

print_table_header "SYSTEM DETAILS"



# Get system information

KERNEL=$(uname -r)

ARCHITECTURE=$(uname -m)

HOSTNAME=$(hostname)

OS=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Unknown")

MEMORY_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')

MEMORY_USED=$(free -h | awk '/^Mem:/ {print $3}')

CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2- | sed 's/^[ \t]*//' | head -1 || echo "Unknown")

CPU_CORES=$(nproc --all)

UPTIME=$(uptime -p | sed 's/^up //')



# Print detailed system information in a fancy table

print_table_row "Hostname" "$HOSTNAME"

print_table_row "OS" "$OS"

print_table_row "Kernel" "$KERNEL"

print_table_row "Architecture" "$ARCHITECTURE"

print_table_row "CPU" "$CPU_MODEL ($CPU_CORES cores)"

print_table_row "Memory" "$MEMORY_USED used of $MEMORY_TOTAL"

print_table_row "Uptime" "$UPTIME"

print_table_row "Date" "$(date "+%a %b %d %H:%M:%S %Y")"

print_table_footer

# QNN Information with fancy graphics

print_header "QNN INFORMATION"

# Show fancy QNN ASCII art
echo -e "${YELLOW}"

echo "      ██████╗ ███╗   ██╗███╗   ██╗"

echo "     ██╔═══██╗████╗  ██║████╗  ██║"

echo "     ██║   ██║██╔██╗ ██║██╔██╗ ██║"

echo "     ██║   ██║██║╚██╗██║██║╚██╗██║"

echo "     ╚██████╔╝██║ ╚████║██║ ╚████║"

echo "      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝"

echo "          ██║"

echo "           ╚╝"

echo -e "${NC}"




echo -ne "? Detecting QNN backend... "
for i in {1..10}; do
    echo -ne "¦ "
    sleep 0.05
done
echo

# QNN SDK Version Check
# Capture full output (stdout and stderr)
full_out=$(qnn-net-run --version 2>&1)

# Extract the line containing the SDK version
QNN_SDK_LINE=$(echo "$full_out" | grep "QNN SDK v")
# Parse out the version number (after 'v')
QNN_SDK_VER=$(echo "$QNN_SDK_LINE" | awk -F'v' '{print $2}')

print_table_header "QNN RUNTIME DETAILS"
if [[ -n "$QNN_SDK_VER" ]]; then
	QNN_SDK_VER=$(echo "$QNN_SDK_VER" | cut -d'.' -f1-3)
	print_table_row "QNN SDK Version" "$QNN_SDK_VER"
else
    print_table_row "QNN SDK Version" "Not Found"
fi

echo

# Run qnn-platform-validator, capture output
QNN_OUTPUT=$(qnn-platform-validator --backend all --coreVersion --libVersion --testBackend 2>&1)

# Extract Backend blocks info - GPU and DSP
for backend in GPU DSP; do
  # Extract the block between "Backend = $backend" and the next "Backend ="
  block=$(echo "$QNN_OUTPUT" | sed -n "/Backend = $backend/,/Backend =/p" | sed '$d')

  # Parse each field from the block
  backend_hw=$(echo "$block" | grep -i "Backend Hardware" | awk -F':' '{print $2}' | xargs)
  backend_lib=$(echo "$block" | grep -i "Backend Libraries" | awk -F':' '{print $2}' | xargs)
  lib_version=$(echo "$block" | grep -i "Library Version" | awk -F':' '{print $2}' | xargs)
  core_version=$(echo "$block" | grep -i "Core Version" | awk -F':' '{print $2}' | xargs)
  unit_test=$(echo "$block" | grep -i "Unit Test" | awk -F':' '{print $2}' | xargs)
  
  if [[ "$backend" == "GPU" ]]; then
    QNN_GPU_TEST_RESULT="$unit_test"
  elif [[ "$backend" == "DSP" ]]; then
    QNN_DSP_TEST_RESULT="$unit_test"
  fi

  print_table_row "Backend" "$backend"
  print_table_row "Backend Hardware" "$backend_hw"
  print_table_row "Backend Libraries" "$backend_lib"
  print_table_row "Library Version" "$lib_version"
  print_table_row "Core Version" "$core_version"
  print_table_row "Unit Test" "$unit_test"
  echo
done

print_table_footer

# SNPE Information with ASCII logo and details

print_header "SNPE INFORMATION"
echo -e "${CYAN}"
echo "       ██████╗███╗   ██╗██████╗ ███████╗"
echo "      ██╔════╝████╗  ██║██╔══██╗██╔════╝"
echo "       ████╗  ██╔██╗ ██║██████╔╝█████╗  "
echo "      ╚════██╗██║╚██╗██║██╔═══╝ ██╔══╝  "
echo "      ██████╔╝██║ ╚████║██║     ███████╗"
echo "      ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚══════╝"
echo -e "${NC}"


# Animated detection
echo -ne "? Detecting SNPE runtimes... "
for i in {1..10}; do
    echo -ne "¦ "
    sleep 0.05
done
echo

# SNPE SDK Version Check
# Capture full output (both stdout and stderr)
snpe_full_out=$(snpe-net-run --version 2>&1)

# Extract the version line that starts with "SNPE v"
SNPE_SDK_LINE=$(echo "$snpe_full_out" | grep "^SNPE v")

# Trim off the 'SNPE v' prefix
SNPE_SDK_VER=$(echo "$SNPE_SDK_LINE" | awk -F'v' '{print $2}')

print_table_header "SNPE RUNTIME DETAILS"

if [[ -n "$SNPE_SDK_VER" ]]; then
    SNPE_SDK_VER=$(echo "$SNPE_SDK_VER" | cut -d'.' -f1-3)
    print_table_row "SNPE SDK Version" "$SNPE_SDK_VER "
else
    print_table_row "SNPE SDK Version" "Not Found"
fi

# Run snpe-platform-validator with timeout and capture output
# Capture clean SNPE validator output (nulls removed)
SNPE_OUTPUT=$(timeout 1 snpe-platform-validator --runtime all --coreVersion --libVersion --testRuntime 2>/dev/null | tr -d '\0')

parse_snpe_runtime() {
    local RUNTIME_NAME=$1
    # No warnings, clean output
    UNIT_TEST_LINE=$(echo "$SNPE_OUTPUT" | grep "Unit Test on the runtime $RUNTIME_NAME")
    UNIT_TEST_RESULT=$(echo "$UNIT_TEST_LINE" | awk -F':' '{print $2}' | xargs)

    if [[ -n "$UNIT_TEST_RESULT" ]]; then
        print_table_row "$RUNTIME_NAME Runtime Unit Test" "$UNIT_TEST_RESULT"
    else
        print_table_row "$RUNTIME_NAME Runtime Unit Test" "Not Detected"
    fi
}

# Parse GPU and DSP runtime results
parse_snpe_runtime "GPU"
parse_snpe_runtime "DSP"

print_table_footer

# ----------------------------
# MLC Check
# ----------------------------
print_header "MLC SDK Check"

# Initialize conda for bash shell
source "$(conda info --base)/etc/profile.d/conda.sh"

# Activate conda env
echo "Activating conda environment: mlc-venv"
conda activate mlc-venv

echo -e "${YELLOW}"
echo "███╗   ███╗██╗      ██████╗";
echo "████╗ ████║██║     ██╔════╝";
echo "██╔████╔██║██║     ██║     ";
echo "██║╚██╔╝██║██║     ██║     ";
echo "██║ ╚═╝ ██║███████╗╚██████╗";
echo "╚═╝     ╚═╝╚══════╝ ╚═════╝";
echo "                           ";
echo -e "${NC}"

print_info "Checking for MLC installation and version..."

MLC_OUTPUT=$(python -c "import mlc_llm; print('STATUS: Installed'); print('VERSION:', mlc_llm.__version__)" 2>&1)

MLC_STATUS=$(echo "$MLC_OUTPUT" | grep "STATUS:" | awk -F':' '{print $2}' | xargs)
MLC_VERSION=$(echo "$MLC_OUTPUT" | grep "VERSION:" | awk -F':' '{print $2}' | xargs)
MLC_ERROR=$(echo "$MLC_OUTPUT" | grep -i "Traceback\|Error" | xargs)

print_table_row "MLC Status" "${MLC_STATUS:-Not Found}"
print_table_row "MLC Version" "${MLC_VERSION:-N/A}"
if [[ -n "$MLC_ERROR" ]]; then
    print_table_row "MLC Error" "$MLC_ERROR"
fi
# ----------------------------
# MLC Inference Check
# ----------------------------

MODEL="$MLC_MODEL_NAME"
MODEL_DIR="$MLC_MODEL_PATH"
MODEL_LIB="$MODEL_LIB"
MLC_CLI="$MLC_CLI_BIN"

print_info "Checking for model inference support..."
print_table_header "MLC Model inference using '$MODEL' Model"

# Function to run inference validation
run_inference_validation() {
    START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    START_EPOCH=$(date +%s)
    echo "Start Time: $START_TIME"

    # Run inference with timeout of 30s, capture only the first 10 lines
    OUTPUT=$(timeout 30s "$MLC_CLI" \
          --model "$MODEL_DIR" \
          --model-lib "$MODEL_LIB" \
          --device opencl \
          --with-prompt "What is the capital of France" 2>&1 | head -n 10)
    EXIT_CODE=$?

    END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    END_EPOCH=$(date +%s)
    ELAPSED=$((END_EPOCH - START_EPOCH))
    echo "End Time: $END_TIME"
    echo "Elapsed Time: ${ELAPSED}s"

    if [ $EXIT_CODE -eq 124 ]; then
        echo "? FAIL: Model did not respond within 30 seconds."
        print_table_row "MLC Inference" "N/A" "Timeout"
    elif echo "$OUTPUT" | grep -q .; then
        echo "? SUCCESS: Model produced output."
        echo "Sample Output:"
        echo "$OUTPUT" | sed -n '10p'
        print_table_row "MLC LLM Inference" "Success" "Output Generated"
    else
        echo "? FAIL: Model ran but no output produced."
        print_table_row "MLC LLM Inference" "Fail" "No Output"
    fi

}

# --- Validation before running inference ---
if [[ ! -d "$MODEL_DIR" ]]; then
    echo "? ERROR: Model directory '$MODEL_DIR' not found. Skipping inference."
    print_table_row "MLC Inference" "N/A" "Model Missing"
elif [[ ! -f "$MODEL_LIB" ]]; then
    echo "? ERROR: Model library '$MODEL_LIB' not found. Skipping inference."
    print_table_row "MLC Inference" "N/A" "Library Missing"
else
    run_inference_validation   
fi

# ----------------------------
# TVM Check
# ----------------------------
print_header "TVM SDK Check"

echo -e "${BLUE}"
echo "████████╗██╗   ██╗███╗   ███╗";
echo "╚══██╔══╝██║   ██║████╗ ████║";
echo "   ██║   ██║   ██║██╔████╔██║";
echo "   ██║   ╚██╗ ██╔╝██║╚██╔╝██║";
echo "   ██║    ╚████╔╝ ██║ ╚═╝ ██║";
echo "   ╚═╝     ╚═══╝  ╚═╝     ╚═╝";
echo "                             ";
echo -e "${NC}"

print_info "Checking for TVM installation and version..."

TVM_OUTPUT=$(python -c "import tvm; print('STATUS: Installed'); print('VERSION:', tvm.__version__)" 2>&1)

TVM_STATUS=$(echo "$TVM_OUTPUT" | grep "STATUS:" | awk -F':' '{print $2}' | xargs)
TVM_VERSION=$(echo "$TVM_OUTPUT" | grep "VERSION:" | awk -F':' '{print $2}' | xargs)
TVM_ERROR=$(echo "$TVM_OUTPUT" | grep -i "Traceback\|Error" | xargs)

print_table_row "TVM Status" "${TVM_STATUS:-Not Found}"
print_table_row "TVM Version" "${TVM_VERSION:-N/A}"
if [[ -n "$TVM_ERROR" ]]; then
    print_table_row "TVM Error" "$TVM_ERROR"
fi


print_header "FINAL SUMMARY TABLE"
print_table_header "Summary Results"

# QNN GPU Backend
if [[ "$QNN_GPU_TEST_RESULT" == "Passed" ]]; then
    print_summary_table_row "QNN GPU Backend" "$QNN_SDK_VER" "Supported"
else
    print_summary_table_row "QNN GPU Backend" "$QNN_SDK_VER" "Not Supported"
fi

# QNN DSP Backend
if [[ "$QNN_DSP_TEST_RESULT" == "Passed" ]]; then
    print_summary_table_row "QNN DSP Backend" "$QNN_SDK_VER" "Supported"
else
    print_summary_table_row "QNN DSP Backend" "$QNN_SDK_VER" "Not Supported"
fi

# SNPE GPU
if echo "$SNPE_OUTPUT" | grep -q "Unit Test on the runtime GPU.*Passed"; then
    print_summary_table_row "SNPE GPU Runtime" "$SNPE_SDK_VER" "Supported"
else
    print_summary_table_row "SNPE GPU Runtime" "$SNPE_SDK_VER" "Not Supported"
fi

# SNPE DSP
if echo "$SNPE_OUTPUT" | grep -q "Unit Test on the runtime DSP.*Passed"; then
    print_summary_table_row "SNPE DSP Runtime" "$SNPE_SDK_VER" "Supported"
else
    print_summary_table_row "SNPE DSP Runtime" "$SNPE_SDK_VER" "Not Supported"
fi

# MLC Verification
if [[ "$MLC_STATUS" == "Installed" ]]; then
    print_summary_table_row "MLC SDK" "$MLC_VERSION" "Supported"
else
    print_summary_table_row "MLC SDK" "$MLC_VERSION" "Not Supported"
fi

# TVM Verification
if [[ "$TVM_STATUS" == "Installed" ]]; then
    print_summary_table_row "TVM SDK" "$TVM_VERSION" "Supported"
else
    print_summary_table_row "TVM SDK" "$TVM_VERSION" "Not Supported"
fi




#############################################
print_header "MLC LLM + LANGCHAIN + FAISS CHECK"

MAX=3
MLC_STATUS=0
INFERENCE_STATUS=0
LANGCHAIN_STATUS=0
FAISS_STATUS=0

# ---- Check if MLC CLI exists ----
if command -v "$MLC_CLI_BIN" >/dev/null 2>&1; then
    print_table_row "MLC CLI" "✓ Available"
    MLC_STATUS=1
    MAX=$((MAX + 1))

    # ---- Run basic inference ----
    RESPONSE=$("$MLC_CLI_BIN" \
    --model "$MLC_MODEL_PATH" \
    --device "$MLC_DEVICE" \
    --model-lib "$MODEL_LIB" \
    --with-prompt "Hi! How are you?" 2>&1)

    # ---- Clean extraction: after 2nd """ to before 'decode' ----
    CLEAN_RESPONSE=$(echo "$RESPONSE" | \
      awk 'BEGIN{q=0}
           /"""/ {q++}
           q>1 && /decode/{exit}
           q>1 && !/"""/ && !/W\/Adreno/ && !/\/help|\/exit|\/stats|Multi-line/ && NF' | \
      sed '/^$/d')

    # ---- Compact one-line preview for table ----
    SHORT_MSG=$(echo "$CLEAN_RESPONSE" | head -n 3 | paste -sd' ' - | cut -c1-200)

    [[ -z "$SHORT_MSG" ]] && SHORT_MSG="Response detected"

    # ---- Determine success or failure ----
    if [ -n "$CLEAN_RESPONSE" ]; then
        INFERENCE_STATUS=1
        print_table_row "MLC Test Inference (Hi, How are you?)" "✓ $SHORT_MSG"
    elif echo "$RESPONSE" | grep -qi "error"; then
        print_table_row "MLC Test Inference (Hi, How are you?)" "⚠ Error during run"
    else
        print_table_row "MLC Test Inference (Hi, How are you?)" "⚠ No valid response"
    fi

else
    print_table_row "MLC CLI" "⚠ Not Found"
fi


# ---- Check LangChain installation ----
LANGCHAIN_STATUS=$(python3 -c "
try:
    import langchain
    print('Installed')
except:
    print('Not Installed')
" 2>/dev/null)

if [[ "$LANGCHAIN_STATUS" == "Installed" ]]; then
    LANGCHAIN_STATUS=1
    print_table_row "LangChain" "✓ Available"
else
    print_table_row "LangChain" "⚠ Not Available"
fi


# ---- Check FAISS installation ----
FAISS_INSTALLATION_STATUS=$(python3 -c "
try:
    import faiss
    print('Installed')
except:
    print('Not Installed')
" 2>/dev/null)

if [[ "$FAISS_INSTALLATION_STATUS" == "Installed" ]]; then
    FAISS_STATUS=1
    print_table_row "FAISS" "✓ Available"
else
    print_table_row "FAISS" "⚠ Not Available"
fi


# ---- Calculate overall score ----
TOTAL=$((MLC_STATUS + INFERENCE_STATUS + LANGCHAIN_STATUS + FAISS_STATUS))
PERCENTAGE=$((TOTAL * 100 / MAX))

print_table_row "Overall Score" "$PERCENTAGE% ($TOTAL/$MAX)"


# ---- Visual progress bar ----
BAR_SIZE=20
FILLED=$((BAR_SIZE * TOTAL / MAX))
EMPTY=$((BAR_SIZE - FILLED))

BAR=""
for ((i=0; i<FILLED; i++)); do
    BAR="${BAR}█"
done
for ((i=0; i<EMPTY; i++)); do
    BAR="${BAR}░"
done

print_table_row "Progress" "$BAR"




print_table_footer



echo -e "${BOLD}>>> Diagnostic Completed at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo


# At the end, restore original stdout and stderr
exec >&3 2>&4
exec 3>&- 4>&-

exit 0
