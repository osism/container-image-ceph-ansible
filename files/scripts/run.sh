#!/usr/bin/env bash

set -e

source /secrets.sh

ENVIRONMENT=${ENVIRONMENT:-ceph}
SUB=${SUB:-ceph}

if [[ $# -lt 1 ]]; then
    echo usage: osism-$ENVIRONMENT SERVICE [...]
    exit 1
fi

services=$1
shift

ANSIBLE_DIRECTORY=/ansible
CONFIGURATION_DIRECTORY=/opt/configuration
ENVIRONMENTS_DIRECTORY=$CONFIGURATION_DIRECTORY/environments
VAULT=${VAULT:-$ENVIRONMENTS_DIRECTORY/.vault_pass}

export ANSIBLE_INVENTORY=$ANSIBLE_DIRECTORY/inventory/hosts.yml

if [[ -e /ansible/ara.env ]]; then
    source /ansible/ara.env
fi

export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/ansible.cfg
if [[ -e /inventory/ansible/ansible.cfg ]]; then
    export ANSIBLE_CONFIG=/inventory/ansible/ansible.cfg
elif [[ -e $ENVIRONMENTS_DIRECTORY/$SUB/ansible.cfg ]]; then
    export ANSIBLE_CONFIG=$ENVIRONMENTS_DIRECTORY/$SUB/ansible.cfg
fi

if [[ -w $ANSIBLE_INVENTORY ]]; then
    rsync -a /ansible/group_vars/ /ansible/inventory/group_vars/
    rsync -a /ansible/inventory.generics/ /ansible/inventory/
    rsync -a /opt/configuration/inventory/ /ansible/inventory/
    python3 /src/handle-inventory-overwrite.py
    cat /ansible/inventory/[0-9]* > /ansible/inventory/hosts
    rm /ansible/inventory/[0-9]*
fi

if [[ -e $ENVIRONMENTS_DIRECTORY/$SUB/.lock ]]; then
    echo "ERROR: The environment $SUB is locked via the configuration repository."
    exit 1
fi

cd $ENVIRONMENTS_DIRECTORY/$SUB

export IFS=","
for service in $services; do
  if [[ -e $ENVIRONMENTS_DIRECTORY/$SUB/playbook-$service.yml ]]; then
    ansible-playbook \
      --vault-password-file $VAULT \
      -e @$ENVIRONMENTS_DIRECTORY/configuration.yml \
      -e @$ENVIRONMENTS_DIRECTORY/secrets.yml \
      -e @secrets.yml \
      -e @images.yml \
      -e @configuration.yml \
      --skip-tags=with_pkg \
      "$@" \
      playbook-$service.yml
  elif [[ -e $ANSIBLE_DIRECTORY/$ENVIRONMENT-$service.yml ]]; then
    ansible-playbook \
      --vault-password-file $VAULT \
      -e @$ENVIRONMENTS_DIRECTORY/configuration.yml \
      -e @$ENVIRONMENTS_DIRECTORY/secrets.yml \
      -e @secrets.yml \
      -e @images.yml \
      -e @configuration.yml \
      --skip-tags=with_pkg \
      "$@" \
      $ANSIBLE_DIRECTORY/$ENVIRONMENT-$service.yml
  else
    echo "ERROR: service $service in environment $ENVIRONMENT not available"
    exit 1
  fi
done
