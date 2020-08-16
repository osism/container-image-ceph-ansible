#!/usr/bin/env bash

# Available environment variables
#
# CEPH_VERSION
# REPOSITORY
# VERSION

CEPH_VERSION=${CEPH_VERSION:-nautilus}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

COMMIT=$(git rev-parse --short HEAD)

sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

if [[ $CEPH_VERSION == "master" ]]; then
    tag=$REPOSITORY:latest
else
    tag=$REPOSITORY:$CEPH_VERSION
fi

trivy image --clear-cache
trivy image "$tag-$COMMIT"
