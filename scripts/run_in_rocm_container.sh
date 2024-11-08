#!/bin/bash

set -ex

# sudo usermod -a -G render,video $LOGNAME
# sudo chmod u+s /opt/rocm-6.2.2/lib/llvm/bin/amdgpu-arch

export MILABENCH_GPU_ARCH=rocm
export MILABENCH_WORDIR="$(pwd)/$MILABENCH_GPU_ARCH"
export ROCM_PATH="/opt/rocm"
export MILABENCH_BASE="$MILABENCH_WORDIR/results"
export MILABENCH_VENV="$MILABENCH_WORDIR/env"
export BENCHMARK_VENV="$MILABENCH_WORDIR/results/venv/torch"

if [ -z "${MILABENCH_SOURCE}" ]; then
    export MILABENCH_CONFIG="$MILABENCH_WORDIR/milabench/config/standard.yaml"
else
    export MILABENCH_CONFIG="$MILABENCH_SOURCE/config/standard.yaml"
fi


export GPU="$(/opt/rocm/lib/llvm/bin/amdgpu-arch | head -n 1)"
export TORCH_ROCM_ARCH_LIST="$GPU"
export ROCM_TARGETS="$GPU"
export PYTORCH_ROCM_ARCH="$GPU"

export MILABENCH_HF_TOKEN=###_YOUR_TOKEN_HERE_##########
export TORCHELASTIC_ERROR_FILE=/milabench/rocm/results/runs/mp_error_trace

(
    . $BENCHMARK_VENV/bin/activate

    # experiment on package versions to get mp benchmarks working
    #pip uninstall -y torchao
    #pip uninstall -y torchtune
    #pip install torchao==0.6.1 # Earlier 0.3.1
    #pip install torchtune==0.3.1 # Earlier 0.2.1
    huggingface-cli login --token $MILABENCH_HF_TOKEN
)


ARGS="$@"

# Activate milabench venv:

. $MILABENCH_WORDIR/env/bin/activate


milabench prepare $ARGS 

#
#   Run the benchmakrs


milabench run $ARGS

#
#   Display report
milabench report --runs $MILABENCH_WORDIR/results/runs
