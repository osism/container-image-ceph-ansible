#!/usr/bin/env bash
set -x

# Available environment variables
#
# CEPH_VERSION
# DOCKER_REGISTRY
# REPOSITORY
# VERSION

# Set default values

CEPH_VERSION=${CEPH_VERSION:-luminous}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-index.docker.io}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

if [[ -n $TRAVIS_TAG ]]; then
    VERSION=${TRAVIS_TAG:1}
fi

COMMIT=$(git rev-parse --short HEAD)

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $CEPH_VERSION == "master" ]]; then
    tag=$REPOSITORY:latest

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
else
    tag=$REPOSITORY:$CEPH_VERSION

    docker tag "$tag-$COMMIT" "$tag-$VERSION"
    docker push "$tag-$VERSION"

    if [[ -z $TRAVIS_TAG ]]; then
        docker tag "$tag-$COMMIT" "$tag"
        docker push "$tag"
    fi
fi
