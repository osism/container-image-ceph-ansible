#!/usr/bin/env bash

mkdir -p /interface/ceph-ansible /interface/versions
rsync -am --exclude='requirements*.yml' --include='*.yml' --exclude='*' /ansible/ /interface/ceph-ansible/
cp /ansible/group_vars/all/versions.yml /interface/versions/ceph-ansible.yml

exec /usr/bin/dumb-init -- "$@"
