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

COMMIT=$(git rev-parse --short HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $PUSH_COMMIT == "true" ]]; then
    docker push "$REPOSITORY:$VERSION-$COMMIT"
fi

docker tag "$REPOSITORY:$CEPH_VERSION-$VERSION-$COMMIT" "$REPOSITORY:$CEPH_VERSION-$VERSION"
docker push "$REPOSITORY:$CEPH_VERSION-$VERSION"
