#!/usr/bin/env bash
set -x

# Available environment variables
#
# CEPH_VERSION
# DOCKER_REGISTRY
# REPOSITORY
# VERSION

# Set default values

CEPH_VERSION=${CEPH_VERSION:-nautilus}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

COMMIT=$(git rev-parse --short HEAD)

. defaults/$CEPH_VERSION.sh

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

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
fi
