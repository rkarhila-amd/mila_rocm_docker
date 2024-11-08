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

mkdir -p $MILABENCH_WORDIR
cd $MILABENCH_WORDIR

virtualenv $MILABENCH_WORDIR/env

if [ -z "${MILABENCH_SOURCE}" ]; then
    if [ ! -d "$MILABENCH_WORDIR/milabench" ]; then
        git clone https://github.com/mila-iqia/milabench.git -b rocm
    fi
    export MILABENCH_SOURCE="$MILABENCH_WORDIR/milabench"
fi

. $MILABENCH_WORDIR/env/bin/activate

pip install -e $MILABENCH_SOURCE

#
# Install milabench's benchmarks in their venv
#
# pip install torch --index-url https://download.pytorch.org/whl/rocm6.1
# milabench pin --variant rocm --from-scratch $ARGS 
milabench install $ARGS 

 #
    # Override/add package to milabench venv here
    #
    which pip
    pip uninstall pynvml

    # We're entering a venv within a venv:
        . $BENCHMARK_VENV/bin/activate

        pip install ninja

        if [ -z "${MILABENCH_HF_TOKEN}" ]; then
            echo "Missing token"
        else
            huggingface-cli login --token $MILABENCH_HF_TOKEN
        fi

        #
        # Override/add package to the benchmark venv here
        #
        which pip

        # Fix the version of jax:
        python3 -m pip install https://github.com/ROCm/jax/releases/download/rocm-jaxlib-v0.4.30/jaxlib-0.4.30+rocm611-cp310-cp310-manylinux2014_x86_64.whl
        pip install https://github.com/ROCm/jax/archive/refs/tags/rocm-jaxlib-v0.4.30.tar.gz

        # Uninstall some pytorch extensions:
        pip uninstall torch_cluster torch_scatter torch_sparse -y
        FORCE_ONLY_CUDA=1 pip install -U -v --use-pep517 --no-build-isolation git+https://github.com/rusty1s/pytorch_cluster.git
        FORCE_ONLY_CUDA=1 pip install -U -v --use-pep517 --no-build-isolation git+https://github.com/rusty1s/pytorch_scatter.git
        FORCE_ONLY_CUDA=1 pip install -U -v --use-pep517 --no-build-isolation git+https://github.com/rusty1s/pytorch_sparse.git

# That's it! We'll continue in the next docker step!