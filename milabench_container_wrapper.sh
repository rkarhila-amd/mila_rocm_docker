#!/bin/bash

#export MILABENCH_IMAGE=ghcr.io/rkarhila-amd/milabench_rocm:torch2.5.1-mi250mi300-2024-11-07
#export MILABENCH_IMAGE=ghcr.io/rkarhila-amd/mila-rocm-docker:torch2.5.1-mi250mi300-2024-11-09
export MILABENCH_IMAGE=ghcr.io/rkarhila-amd/mila-rocm-docker:torch2.5.1-mi250mi300-2024-11-09_patched
# Pull the image we are going to run
docker pull $MILABENCH_IMAGE

export MILABENCH_CONTAINER_NAME=rkarhila_mila_torch251

#TODAY_DATE=$(date +"%Y-%m-%d")

#docker tag $MILABENCH_IMAGE ${MILABENCH_IMAGE}-${TODAY_DATE}

# Run milabench

# debug mode: let's keep container persistent for now. If it exists,
# do a docker exec instead:
set -x

# if [ "$( docker container inspect -f '{{.State.Status}}' $MILABENCH_CONTAINER_NAME )" = "running" ]; then
#       echo "Using an existing, running container"
#       docker exec -it $MILABENCH_CONTAINER_NAME /tmp/scripts/run_in_rocm_container.sh $@
# elif [ "$( docker container inspect -f '{{.State.Status}}' $MILABENCH_CONTAINER_NAME )" = "created" ]; then
#       echo "Using an existing, stopped container"
#       docker container start $MILABENCH_CONTAINER_NAME
#       docker exec -it $MILABENCH_CONTAINER_NAME /tmp/scripts/run_in_rocm_container.sh $@
# else
      echo "Starting a new container"
      docker run -it --rm --ipc=host                                                  \
            --device=/dev/kfd --device=/dev/dri                                        \
            --security-opt seccomp=unconfined --group-add video                        \
            -v $(pwd)/scripts:/tmp/scripts \
            -v $(pwd)/results/runs/:/milabench/rocm/results/runs                         \
            -v $(pwd)/results/data/:/milabench/rocm/results/data                         \
            -v $(pwd)/results/cache/:/milabench/rocm/results/cache                       \
            -v $(pwd)/milabench:/milabench/rocm/milabench                                \
            -v $(pwd)/recipe_fixes/llm/recipes:/milabench/rocm/milabench/benchmarks/llm/milarecipes \
            --name $MILABENCH_CONTAINER_NAME                                                     \
            $MILABENCH_IMAGE                                                           \
            /tmp/scripts/run_in_rocm_container.sh $@
#fi

#      -v $(pwd)/venv/rocm/:/milabench/rocm                             \
#      -v $(pwd)/results:/milabench/envs/runs                                     \
#      -v /opt/amdgpu/share/libdrm/amdgpu.ids:/opt/amdgpu/share/libdrm/amdgpu.ids \
#      -v $(pwd)/milabench-rocm/:/milabench/milabench                             \
