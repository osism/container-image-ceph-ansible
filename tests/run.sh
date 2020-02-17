#!/usr/bin/env bash
set -x

ENVIRONMENT=ceph

if [[ $# -lt 1 ]]; then
    echo usage: osism-$ENVIRONMENT SERVICE [...]
    exit 1
fi

services=$1
shift

ANSIBLE_DIRECTORY=/ansible
CONFIGURATION_DIRECTORY=/opt/configuration
ENVIRONMENTS_DIRECTORY=$CONFIGURATION_DIRECTORY/environments

export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/ansible.cfg
if [[ -e $ENVIRONMENTS_DIRECTORY/$ENVIRONMENT/ansible.cfg ]]; then
    export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/$ENVIRONMENT/ansible.cfg
fi

cd $ENVIRONMENTS_DIRECTORY/$ENVIRONMENT

export IFS=","
for service in $services; do
  ansible-playbook \
    -e CONFIG_DIR=$ENVIRONMENTS_DIRECTORY/$ENVIRONMENT \
    -e @secrets.yml \
    -e @images.yml \
    -e @configuration.yml \
    --skip-tags=with_pkg \
    "$@" \
    $ANSIBLE_DIRECTORY/$ENVIRONMENT-$service.yml
done
