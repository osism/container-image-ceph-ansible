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
CREATED=$(date --rfc-3339=ns)
DOCKER_REGISTRY=${DOCKER_REGISTRY:-index.docker.io}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
REVISION=$(git rev-parse --short HEAD)
VERSION=${VERSION:-latest}

if [[ -n $TRAVIS_TAG ]]; then
    VERSION=${TRAVIS_TAG:1}
fi

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $CEPH_VERSION == "master" ]]; then
    TAG=$REPOSITORY:latest
else
    TAG=$REPOSITORY:$CEPH_VERSION
fi

docker build \
    --build-arg "CEPH_VERSION=$CEPH_VERSION" \
    --build-arg "VERSION=$VERSION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.version=$VERSION" \
    --no-cache \
    --squash \
    --tag "$TAG-$(git rev-parse --short HEAD)" \
    $BUID_OPTS .
