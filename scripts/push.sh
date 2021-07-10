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

# NOTE: For builds for a specific release, the Ceph version is taken from the release repository.
if [[ $VERSION != "latest" ]]; then
    filename=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/ceph.yml)
    CEPH_VERSION=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/$filename.yml | grep "ceph_version:" | awk -F': ' '{ print $2 }')
fi

. defaults/$CEPH_VERSION.sh

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $CEPH_VERSION == "master" ]]; then
    tag=$REPOSITORY:latest

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
else
    if [[ $VERSION == "latest" ]]; then
        tag=$REPOSITORY:$CEPH_VERSION
    else
        tag=$REPOSITORY:$VERSION
    fi

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
fi
