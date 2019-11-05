#!/usr/bin/env bash
set -x

# Available environment variables
#
# BUILD_OPTS
# CEPH_VERSION
# DOCKER_REGISTRY
# REPOSITORY
# VERSION

# Set default values

BUILD_OPTS=${BUILD_OPTS:-}
CEPH_VERSION=${CEPH_VERSION:-luminous}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-index.docker.io}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

HASH_REPOSITORY=$(git rev-parse --short HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

TAG=$REPOSITORY:$CEPH_VERSION-$VERSION

docker build \
    --build-arg "CEPH_VERSION=$CEPH_VERSION" \
    --build-arg "VERSION=$VERSION" \
    --label "io.osism.ceph-ansible=$HASH_REPOSITORY" \
    --no-cache \
    --squash \
    --tag "$TAG-$(git rev-parse --short HEAD)" \
    $BUID_OPTS .
