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

virtualenv $MILABENCH_WORDIR/env

if [ -z "${MILABENCH_SOURCE}" ]; then
    export MILABENCH_SOURCE="$MILABENCH_WORDIR/milabench"
fi

. $MILABENCH_WORDIR/env/bin/activate

    # Remove these packages (again?)
    #pip uninstall pynvml nvidia-ml-py -y


    # We're entering a venv within a venv again, to finish the job with xformers and flash attention
    . $BENCHMARK_VENV/bin/activate

    pip uninstall flash-attention
    GPU_ARCHS="gfx90a;gfx942" pip install -v -U --no-build-isolation --use-pep517 --no-deps git+https://github.com/ROCm/flash-attention.git 

    pip uninstall pynvml nvidia-ml-py -y

    pip install einops

    pip uninstall pynvml nvidia-ml-py -y


# That's it! We'll continue in the next docker step!