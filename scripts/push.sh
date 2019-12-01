#!/usr/bin/env bash
set -x

# Available environment variables
#
# CEPH_VERSION
# DOCKER_REGISTRY
# PUSH_COMMIT
# REPOSITORY
# VERSION

# Set default values

CEPH_VERSION=${CEPH_VERSION:-luminous}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-index.docker.io}
PUSH_COMMIT=${PUSH_COMMIT:-false}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

if [[ -n $TRAVIS_TAG ]]; then
    VERSION=${TRAVIS_TAG:1}
fi

COMMIT=$(git rev-parse --short HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $PUSH_COMMIT == "true" ]]; then
    docker push "$REPOSITORY:$VERSION-$COMMIT"
fi

if [[ $CEPH_VERSION == "master" ]]; then
    tag=$REPOSITORY:latest
else
    tag=$REPOSITORY:$CEPH_VERSION-$VERSION
fi

docker tag "$tag-$COMMIT" "$tag"
docker push "$tag"
