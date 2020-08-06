#!/usr/bin/env bash

source /secrets.sh

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

if [[ -e /ansible/ara.env ]]; then
    source /ansible/ara.env
fi

export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/ansible.cfg
if [[ -e $ENVIRONMENTS_DIRECTORY/$ENVIRONMENT/ansible.cfg ]]; then
    export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/$ENVIRONMENT/ansible.cfg
fi

export ANSIBLE_INVENTORY=$ANSIBLE_DIRECTORY/inventory
rsync -a /opt/configuration/inventory/ /ansible/inventory/

cd $ENVIRONMENTS_DIRECTORY/$ENVIRONMENT

export IFS=","
for service in $services; do
  ansible-playbook \
    --vault-password-file $ENVIRONMENTS_DIRECTORY/.vault_pass \
    -e @$ENVIRONMENTS_DIRECTORY/configuration.yml \
    -e @$ENVIRONMENTS_DIRECTORY/secrets.yml \
    -e @secrets.yml \
    -e @images.yml \
    -e @configuration.yml \
    --skip-tags=with_pkg \
    "$@" \
    $ANSIBLE_DIRECTORY/$ENVIRONMENT-$service.yml
done
