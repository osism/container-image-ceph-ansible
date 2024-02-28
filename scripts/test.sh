#!/usr/bin/env bash
set -x

# methods

function deploy() {
    echo "DEPLOY $1"
    docker exec -it test /run.sh deploy $1
}

# available environment variables
#
# DOCKER_REGISTRY
# CEPH_VERSION
# REPOSITORY
# VERSION

# set default values

DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
CEPH_VERSION=${CEPH_VERSION:-quincu}
REPOSITORY=${REPOSITORY:-osism/ceph-ansible}
VERSION=${VERSION:-latest}

COMMIT=$(git rev-parse --short HEAD)

# NOTE: For builds for a specific release, the Ceph version is taken from the release repository.
if [[ $VERSION != "latest" ]]; then
    filename=$(curl -L https://raw.githubusercontent.com/osism/release/main/$VERSION/ceph.yml)
    CEPH_VERSION=$(curl -L https://raw.githubusercontent.com/osism/release/main/$VERSION/$filename | grep "ceph_version:" | awk -F': ' '{ print $2 }')
fi

. defaults/$CEPH_VERSION.sh

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

# run preparations

sudo apt-get install -y python3 python3-docker python3-pip python3-setuptools
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

local_address=$(ip route get 8.8.8.8 | head -1 | cut -d ' ' -f 7)
docker run --rm -v ${PWD}/tests:/workdir mikefarah/yq yq w --inplace /workdir/inventory/host_vars/testnode.yml ansible_host $local_address

sudo modprobe dummy
sudo ip l a dummy_frontend type dummy
sudo ip l a dummy_backend type dummy
sudo ip a a 192.168.70.5/24 dev dummy_frontend
sudo ip a a 192.168.80.5/24 dev dummy_backend
sudo ip l s up dev dummy_frontend
sudo ip l s up dev dummy_backend

for i in $(seq 1 3); do
    free_device=$(sudo losetup -f)
    sudo fallocate -l 1G /var/lib/ceph-$i.img
    sudo losetup $free_device /var/lib/ceph-$i.img
    sudo wipefs -a $free_device

    # NOTE: ceph-container does not work with loop devices
    sudo pvcreate $free_device
    sudo vgcreate vg$i $free_device
    sudo lvcreate -L 128M -n db-lv$i vg$i
    sudo lvcreate -L 128M -n wal-lv$i vg$i
    sudo lvcreate -l 100%FREE -n data-lv$i vg$i
done

lsblk

# start and prepare the ceph-ansible container

docker run --network=host --name test -d \
  -v /etc/hosts:/etc/hosts:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/tests:/opt/configuration:ro" \
  "$COMMIT" sleep infinity
docker cp tests/run.sh test:/run.sh

# prepare ssh

# ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# docker cp $HOME/.ssh/id_rsa test:/ansible/secrets/id_rsa.operator

sudo service ssh start
cat tests/id_rsa.operator.pub >> ~/.ssh/authorized_keys

docker cp tests/id_rsa.operator test:/ansible/secrets/id_rsa.operator

# get facts

docker exec -it test /run.sh facts -v

# run deployment tests

docker exec -it test /run.sh mons -v || exit 1
docker exec -it test /run.sh mgrs -v || exit 1
docker exec -it test /run.sh mdss -v || exit 1

sleep 60

docker ps
docker exec -it ceph-mon-$(hostname) ceph -s
