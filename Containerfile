FROM python:3.13-slim-bookworm AS builder

ARG VERSION
ARG CEPH_VERSION=quincy

ARG USER_ID=45000
ARG GROUP_ID=45000
ARG GROUP_ID_DOCKER=999

ENV DEBIAN_FRONTEND=noninteractive

USER root

COPY --link patches /patches

COPY --link files/library /ansible/library
COPY --link files/tasks /ansible/tasks

COPY --link files/playbooks/$CEPH_VERSION/* /ansible/
COPY --link files/playbooks/*.yml /ansible/
COPY --link files/playbooks/tasks/* /ansible/tasks/
COPY --link files/playbooks/templates/* /ansible/templates/
COPY --link files/playbooks/$CEPH_VERSION/ceph-purge-storage-node.yml /ceph-purge-storage-node.yml
COPY --link files/playbooks/$CEPH_VERSION/ceph-purge-cluster.yml /ceph-purge-cluster.yml

COPY --link files/scripts/* /

COPY --link files/ansible.cfg /etc/ansible/ansible.cfg
COPY --link files/requirements.yml /ansible/galaxy/requirements.yml
COPY --link files/ara.env /ansible/ara.env

COPY --link files/src /src

ADD https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.22.tar.gz /mitogen.tar.gz
COPY --from=ghcr.io/astral-sh/uv:0.6.17 /uv /usr/local/bin/uv

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN <<EOF
set -e
set -x

# show motd
echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' >> /etc/bash.bashrc

# upgrade/install required packages
apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  dumb-init \
  git \
  iputils-ping \
  jq \
  libffi-dev \
  libssh-dev \
  libssl-dev \
  libyaml-dev \
  openssh-client \
  patch \
  procps \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  rsync \
  sshpass
uv pip install --no-cache --system -r /src/requirements.txt

# add user
groupadd -g "$GROUP_ID" dragon
groupadd -g "$GROUP_ID_DOCKER" docker
useradd -l -g dragon -G docker -u "$USER_ID" -m -d /ansible dragon

# prepare release repository
git clone https://github.com/osism/release /release

# run preparations
git clone https://github.com/osism/ansible-playbooks /playbooks
git clone https://github.com/osism/defaults /defaults
git clone https://github.com/osism/cfg-generics /generics

if [ "$VERSION" != "latest" ]; then
  ( cd /release || exit; git fetch --all --force; git checkout "ceph-ansible-$VERSION" )
  ( cd /playbooks || exit; git fetch --all --force; git checkout "$(yq -M -r .playbooks_version "/release/latest/ceph.yml")" )
  ( cd /defaults || exit; git fetch --all --force; git checkout "$(yq -M -r .defaults_version "/release/latest/ceph.yml")" )
  ( cd /generics || exit; git fetch --all --force; git checkout "$(yq -M -r .generics_version "/release/latest/ceph.yml")" )
fi

# add inventory files
mkdir -p /ansible/inventory.generics /ansible/inventory
cp /generics/inventory/50-ceph /ansible/inventory.generics/50-ceph
cp /generics/inventory/51-ceph /ansible/inventory.generics/51-ceph

mkdir -p /ansible/galaxy /ansible/group_vars/all
python3 /src/render-python-requirements.py
python3 /src/render-versions.py
mkdir -p /ansible/group_vars
cp -r /defaults/* /ansible/group_vars/
rm -f /ansible/group_vars/LICENSE /ansible/group_vars/README.md

# install required python packages
uv pip install --no-cache --system -r /requirements.txt

# set ansible version in the motd
ansible_version=$(python3 -c 'import ansible; print(ansible.release.__version__)')
sed -i -e "s/ANSIBLE_VERSION/$ansible_version/" /etc/motd

# create required directories

# internal use only
mkdir -p \
  /ansible \
  /ansible/action_plugins \
  /ansible/callback_plugins \
  /ansible/filter_plugins \
  /ansible/library \
  /ansible/roles \
  /ansible/tasks

# volumes
mkdir -p \
  /ansible/cache \
  /ansible/logs \
  /ansible/secrets \
  /share \
  /interface

# install required ansible collections & roles
ansible-galaxy role install -v -f -r /ansible/galaxy/requirements.yml -p /usr/share/ansible/roles
ln -s /usr/share/ansible/roles /ansible/galaxy
ansible-galaxy collection install -v -f -r /ansible/galaxy/requirements.yml -p /usr/share/ansible/collections
ln -s /usr/share/ansible/collections /ansible/collections

# install mitogen ansible plugin
mkdir -p /usr/share/mitogen
tar xzf /mitogen.tar.gz --strip-components=1 -C /usr/share/mitogen
rm -rf /usr/share/mitogen/{tests,docs,.ci,.lgtm.yml,.travis.yml}
rm /mitogen.tar.gz

# prepare project repository
PROJECT_VERSION=$(grep "ceph_ansible_version:" /release/$VERSION/ceph-$CEPH_VERSION.yml | awk -F': ' '{ print $2 }')
git clone -b $PROJECT_VERSION https://github.com/ceph/ceph-ansible /repository
for patchfile in $(find /patches/$PROJECT_VERSION -name "*.patch"); do
  echo $patchfile;
  ( cd /repository && patch --forward --batch -p1 --dry-run ) < $patchfile || exit 1;
  ( cd /repository && patch --forward --batch -p1 ) < $patchfile;
done

# project specific instructions
if [ -e /repository/plugins/actions ]; then cp /repository/plugins/actions/* /ansible/action_plugins; fi
if [ -e /repository/plugins/callback ]; then cp /repository/plugins/callback/* /ansible/callback_plugins; fi
if [ -e /repository/plugins/filter ]; then cp repository/plugins/filter/* /ansible/filter_plugins; fi
cp /repository/library/* /ansible/library
for playbook in $(find /repository/infrastructure-playbooks -name "*.yml" -maxdepth 1); do echo $playbook && cp $playbook /ansible/ceph-"$(basename $playbook)"; done
cp -r /repository/roles/* /ansible/roles
if [ ! -e /ansible/roles/ceph-container-common ]; then ln -s /ansible/roles/ceph-docker-common /ansible/roles/ceph-container-common; fi
if [ -e /repository/site-docker.yml.sample ]; then cp /repository/site-docker.yml.sample /ansible/ceph-site.ym; fi
if [ -e /repository/site-container.yml.sample ]; then cp /repository/site-container.yml.sample /ansible/ceph-site.ym; fi
if [ -e /repository/dashboard.yml ]; then cp /repository/dashboard.yml /ansible/dashboard.yml; fi
if [ -e /repository/module_utils ]; then cp -r /repository/module_utils /ansible; fi
ln -s /ansible/ceph-rolling_update.yml /ansible/ceph-upgrade.yml

# use our own purge playbooks
rm -f /ansible/ceph-purge-*.yml
mv /ceph-purge-*.yml /ansible

# NOTE(berendt): this is a workaround for ceph-ansible < 3.0.0
mkdir -p \
  /ansible/roles/ceph-config \
  /ansible/roles/ceph-defaults

mkdir -p /tests
cp -r /repository/tests/* /tests

# copy ara configuration
python3 -m ara.setup.env >> /ansible/ara.env

# prepare list of playbooks
python3 /src/render-playbooks.py

# set correct permssions
chown -R dragon: /ansible /share /interface

# cleanup
apt-get clean
apt-get remove -y  \
  build-essential \
  git \
  libffi-dev \
  libssh-dev \
  libssl-dev \
  libyaml-dev \
  python3-dev
apt-get autoremove -y

rm -rf \
  /patches \
  /release \
  /root/.cache \
  /tmp/* \
  /usr/share/doc/* \
  /usr/share/man/* \
  /var/lib/apt/lists/* \
  /var/tmp/*

uv pip install --no-cache --system pyclean==3.0.0
pyclean /usr
uv pip uninstall --system pyclean
EOF

USER dragon

FROM python:3.13-slim-bookworm

COPY --link --from=builder / /

ENV PYTHONWARNINGS="ignore::UserWarning"

VOLUME ["/ansible/secrets", "/ansible/logs", "/ansible/cache", "/share", "/interface"]
USER dragon
WORKDIR /ansible
ENTRYPOINT ["/entrypoint.sh"]
