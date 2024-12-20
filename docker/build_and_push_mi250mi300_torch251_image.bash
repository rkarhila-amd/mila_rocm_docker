#!/bin/bash
set -x
set -e
# Show how to manually build & Push a docker image

ARCH=${ARCH:-rocm}
GHUSER=${USER:-} 
TOKEN=${TOKEN:-} 

TAG="ghcr.io/mila-rocm-docker:torch2.5.1-mi250mi300-$(date +"%Y-%m-%d-%H%M")"


build_docker () {
    # Build docker
    sudo docker build                            \
        -t ${TAG}              \
        --build-arg ARCH=${ARCH}                 \
        --build-arg CONFIG=standard-${ARCH}.yaml \
        --progress=plain                        \
        -f docker/Dockerfile-rocm-mi250mi300_torch251    \
        .  2>&1 | tee "buildlog-$(date +"%Y-%m-%d-%H%M").log"
}

push_docker () {
    # Push the image to github
    echo $TOKEN | docker login ghcr.io -u $GHUSER --password-stdin 
    #docker image tag milabench:${ARCH}-${TAG} ghcr.io/$GHUSER/milabench:${ARCH}-${TAG}
    docker image tag $TAG ghcr.io/$GHUSER/${TAG}
    docker push ghcr.io/$GHUSER/${TAG}
}

build_docker
push_docker