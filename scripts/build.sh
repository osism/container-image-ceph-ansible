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

# NOTE: For builds for a specific release, the Ceph version is taken from the release repository.
if [[ $VERSION != "latest" ]]; then
    filename=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/ceph.yml)
    CEPH_VERSION=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/$filename | grep "ceph_version:" | awk -F': ' '{ print $2 }')
fi

. defaults/$CEPH_VERSION.sh

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

buildah build-using-dockerfile \
    --format docker \
    --build-arg "CEPH_VERSION=$CEPH_VERSION" \
    --build-arg "UBUNTU_VERSION=$UBUNTU_VERSION" \
    --build-arg "VERSION=$VERSION" \
    --label "org.opencontainers.image.created=$CREATED" \
    --label "org.opencontainers.image.documentation=https://docs.osism.tech" \
    --label "org.opencontainers.image.licenses=ASL 2.0" \
    --label "org.opencontainers.image.revision=$REVISION" \
    --label "org.opencontainers.image.source=https://github.com/osism/container-image-ceph-ansible" \
    --label "org.opencontainers.image.title=ceph-ansible" \
    --label "org.opencontainers.image.url=https://www.osism.tech" \
    --label "org.opencontainers.image.vendor=OSISM GmbH" \
    --label "org.opencontainers.image.version=$VERSION" \
    --label "de.osism.release.ceph=$CEPH_VERSION" \
    --tag "$(git rev-parse --short HEAD)" \
    $BUID_OPTS .

buildah push $(git rev-parse --short HEAD) docker-daemon:ceph-ansible:$(git rev-parse --short HEAD)
