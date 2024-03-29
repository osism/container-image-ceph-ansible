#!/usr/bin/env bash

mkdir -p /interface/ceph-ansible /interface/versions /interface/playbooks
rsync -am --exclude='requirements*.yml' --include='*.yml' --exclude='*' /ansible/ /interface/ceph-ansible/
cp /ansible/group_vars/all/versions.yml /interface/versions/ceph-ansible.yml
cp /ansible/playbooks.yml /interface/playbooks/ceph-ansible.yml

exec /usr/bin/dumb-init -- "$@"
