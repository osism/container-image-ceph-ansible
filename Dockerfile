FROM ubuntu:18.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ARG CEPH_VERSION=luminous
ARG MITOGEN_VERSION=0.2.8

ARG USER_ID=45000
ARG GROUP_ID=45000
ARG GROUP_ID_DOCKER=999

ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY patches /patches

COPY files/library /ansible/library
COPY files/plugins /ansible/plugins
COPY files/tasks /ansible/tasks

COPY files/playbooks/* /ansible/
COPY files/scripts/* /

COPY files/ansible.cfg /etc/ansible/ansible.cfg
COPY files/defaults.yml /ansible/group_vars/all/defaults.yml
COPY files/images-$CEPH_VERSION.yml /ansible/group_vars/all/images-project.yml
COPY files/images.yml /ansible/group_vars/all/images.yml
COPY files/requirements.yml /ansible/galaxy/requirements.yml

COPY files/src /src

# show motd

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' >> /etc/bash.bashrc

# upgrade/install required packages

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        git \
        gnupg-agent \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        patch \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        rsync \
        sshpass \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

# add user

RUN groupadd -g $GROUP_ID dragon \
    && groupadd -g $GROUP_ID_DOCKER docker \
    && useradd -g dragon -G docker -u $USER_ID -m -d /ansible dragon

# run preparations

WORKDIR /src
RUN git clone https://github.com/osism/release /release \
    && pip3 install --no-cache-dir -r requirements.txt \
    && mkdir -p /ansible/galaxy /ansible/group_vars/all \
    && python3 /src/render-python-requirements.py \
    && python3 /src/render-versions.py

WORKDIR /

# install required python packages

RUN pip3 install --no-cache-dir -r /requirements.txt

# set ansible version in the motd

RUN ansible_version=$(python3 -c 'import ansible; print(ansible.release.__version__)') \
    && sed -i -e "s/ANSIBLE_VERSION/$ansible_version/" /etc/motd

# create required directories

# internal use only
RUN mkdir -p \
        /ansible \
        /ansible/action_plugins \
        /ansible/library \
        /ansible/roles \
        /ansible/tasks

# exportes as volumes
RUN mkdir -p \
        /ansible/cache \
        /ansible/logs \
        /ansible/secrets \
        /share

# install required ansible roles

RUN ansible-galaxy install -v -f -r /ansible/galaxy/requirements.yml -p /ansible/galaxy

# install required ansible plugins

ADD https://github.com/dw/mitogen/archive/v$MITOGEN_VERSION.tar.gz /mitogen.tar.gz
RUN tar xzf /mitogen.tar.gz --strip-components=1 -C /ansible/plugins/mitogen \
    && rm /mitogen.tar.gz

# prepare project repository

RUN PROJECT_VERSION=$(grep "ceph_ansible_version:" /release/$VERSION/ceph-$CEPH_VERSION.yml | awk -F': ' '{ print $2 }') \
    && git clone -b $PROJECT_VERSION https://github.com/ceph/ceph-ansible /repository \
    && for patchfile in $(find /patches/$PROJECT_VERSION -name "*.patch"); do \
        echo $patchfile; \
        ( cd /repository && patch --forward --batch -p1 --dry-run ) < $patchfile || exit 1; \
        ( cd /repository && patch --forward --batch -p1 ) < $patchfile; \
       done

# project specific instructions

RUN cp /repository/plugins/actions/* /ansible/action_plugins \
    && cp /repository/library/* /ansible/library \
    && for playbook in $(find /repository/infrastructure-playbooks -name "*.yml" -maxdepth 1); do echo $playbook && cp $playbook /ansible/ceph-"$(basename $playbook)"; done \
    && cp -r /repository/roles/* /ansible/roles

# NOTE(berendt): this is a workaround for ceph-ansible < 3.0.0
RUN mkdir -p \
        /ansible/roles/ceph-config \
        /ansible/roles/ceph-defaults

RUN mkdir -p /tests \
    && cp -r /repository/tests/* /tests

RUN python3 -m ara.setup.env > /ansible/ara.env

# set correct permssions

RUN chown -R dragon: /ansible /share

# cleanup

RUN apt-get clean \
    && apt-get remove -y  \
      git \
      libffi-dev \
      libssl-dev \
      libyaml-dev \
      python3-dev \
    && apt-get autoremove -y \
    && rm -rf \
      /patches \
      /release \
      /root/.cache \
      /src \
      /tmp/* \
      /usr/share/doc/* \
      /usr/share/man/* \
      /var/tmp/*

VOLUME ["/ansible/secrets", "/ansible/logs", "/ansible/cache", "/share"]

USER dragon
WORKDIR /ansible

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
