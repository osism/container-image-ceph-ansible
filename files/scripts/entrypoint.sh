#!/usr/bin/env bash

mkdir -p /interface/ceph-ansible
rsync -am --exclude='requirements*.yml' --include='*.yml' --exclude='*' /ansible/ /interface/ceph-ansible/
exec /usr/bin/dumb-init -- "$@"
