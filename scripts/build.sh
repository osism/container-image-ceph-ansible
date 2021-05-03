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
CEPH_VERSION=${CEPH_VERSION:-nautilus}
CREATED=$(date --rfc-3339=ns)
DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
REVISION=$(git rev-parse --short HEAD)
VERSION=${VERSION:-latest}

. defaults/$CEPH_VERSION.sh

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $CEPH_VERSION == "master" ]]; then
    TAG=$REPOSITORY:latest
else
    TAG=$REPOSITORY:$CEPH_VERSION
fi

docker buildx build \
    --load \
    --build-arg "CEPH_VERSION=$CEPH_VERSION" \
    --build-arg "UBUNTU_VERSION=$UBUNTU_VERSION" \
    --build-arg "VERSION=$VERSION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.documentation=https://docs.osism.de" \
    --label "org.opencontainers.image.licenses=ASL 2.0" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.source=https://github.com/osism/container-image-ceph-ansible" \
    --label "org.opencontainers.image.title=ceph-ansible" \
    --label "org.opencontainers.image.url=https://www.osism.de" \
    --label "org.opencontainers.image.vendor=Betacloud Solutions GmbH" \
    --label "org.opencontainers.image.version=$VERSION" \
    --tag "$TAG-$(git rev-parse --short HEAD)" \
    $BUID_OPTS .
