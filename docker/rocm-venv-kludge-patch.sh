#!/bin/bash

set -ex

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

GPU="gfx90a,gfx942"
export TORCH_ROCM_ARCH_LIST="$GPU"
export ROCM_TARGETS="$GPU"
export PYTORCH_ROCM_ARCH="$GPU"



#mkdir -p $MILABENCH_WORDIR
cd $MILABENCH_WORDIR

if [ -z "${MILABENCH_SOURCE}" ]; then
    export MILABENCH_SOURCE="$MILABENCH_WORDIR/milabench"
fi

. $MILABENCH_WORDIR/env/bin/activate

cd /milabench/rocm/milabench
pip install --no-dependencies -e .
pip cache purge

# We're entering a venv within a venv again, to finish the job with xformers and flash attention
. $BENCHMARK_VENV/bin/activate

pip uninstall -y torchao
pip uninstall -y torchtune
pip install torchao==0.6.1 # Earlier 0.3.1
#pip install  torchtune==0.3.1 # torchtune==0.3.1 # Earlier 0.2.1
# Install torchtune from commmit e1caa9f82fea24d728f9b244a9dd1957f5ed7465 from Nov 10th 2024
pip install git+https://github.com/pytorch/torchtune.git@e1caa9f82fea24d728f9b244a9dd1957f5ed7465
pip cache purge



