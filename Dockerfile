ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

ARG VERSION
ARG CEPH_VERSION=nautilus

ARG USER_ID=45000
ARG GROUP_ID=45000
ARG GROUP_ID_DOCKER=999

ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY patches /patches

COPY files/inventory /ansible/inventory
COPY files/library /ansible/library
COPY files/plugins /ansible/plugins
COPY files/tasks /ansible/tasks

COPY files/playbooks/$CEPH_VERSION/* /ansible/
COPY files/scripts/* /

COPY files/ansible.cfg /etc/ansible/ansible.cfg
COPY files/defaults.yml /ansible/group_vars/all/defaults.yml
COPY files/dragon_sudoers /etc/sudoers.d/dragon_sudoers
COPY files/images-$CEPH_VERSION.yml /ansible/group_vars/all/images-project.yml
COPY files/images.yml /ansible/group_vars/all/images.yml
COPY files/requirements.yml /ansible/galaxy/requirements.yml

COPY files/src /src

# add inventory files

ADD https://raw.githubusercontent.com/osism/cfg-generics/master/inventory/50-ceph /ansible/inventory.generics/50-ceph
ADD https://raw.githubusercontent.com/osism/cfg-generics/master/inventory/51-ceph /ansible/inventory.generics/51-ceph

# show motd

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' >> /etc/bash.bashrc

# upgrade/install required packages

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        git \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        openssh-client \
        patch \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        rsync \
        sshpass \
        sudo \
        vim-tiny \
    && python3 -m pip install --upgrade pip \
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
        /ansible/callback_plugins \
        /ansible/filter_plugins \
        /ansible/library \
        /ansible/roles \
        /ansible/tasks

# exportes as volumes
RUN mkdir -p \
        /ansible/cache \
        /ansible/logs \
        /ansible/secrets \
        /share

# install required ansible collections & roles

RUN ansible-galaxy role install -v -f -r /ansible/galaxy/requirements.yml -p /usr/share/ansible/roles \
    && ln -s /usr/share/ansible/roles /ansible/galaxy \
    && ansible-galaxy collection install -v -f -r /ansible/galaxy/requirements.yml -p /usr/share/ansible/collections \
    && ln -s /usr/share/ansible/collections /ansible/collections

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
    && cp /repository/plugins/callback/* /ansible/callback_plugins \
    && if [ -e /repository/plugins/filter ]; then cp repository/plugins/filter/* /ansible/filter_plugins; fi \
    && cp /repository/library/* /ansible/library \
    && for playbook in $(find /repository/infrastructure-playbooks -name "*.yml" -maxdepth 1); do echo $playbook && cp $playbook /ansible/ceph-"$(basename $playbook)"; done \
    && cp -r /repository/roles/* /ansible/roles \
    && if [ ! -e /ansible/roles/ceph-container-common ]; then ln -s /ansible/roles/ceph-docker-common /ansible/roles/ceph-container-common; fi \
    && if [ -e /repository/site-docker.yml.sample ]; then cp /repository/site-docker.yml.sample /ansible/ceph-site.ym; fi \
    && if [ -e /repository/site-container.yml.sample ]; then cp /repository/site-container.yml.sample /ansible/ceph-site.ym; fi \
    && if [ -e /repository/dashboard.yml ]; then cp /repository/dashboard.yml /ansible/dashboard.yml; fi \
    && if [ -e /repository/module_utils ]; then cp -r /repository/module_utils /ansible; fi

# NOTE(berendt): this is a workaround for ceph-ansible < 3.0.0
RUN mkdir -p \
        /ansible/roles/ceph-config \
        /ansible/roles/ceph-defaults

RUN mkdir -p /tests \
    && cp -r /repository/tests/* /tests

# NOTE: Do not activate ARA at Luminous. Not supported by the Ansible version (2.6.x) used there.
RUN if [ $CEPH_VERSION != "luminous" ]; then python3 -m ara.setup.env > /ansible/ara.env; fi

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
      /tmp/* \
      /usr/share/doc/* \
      /usr/share/man/* \
      /var/tmp/*

VOLUME ["/ansible/secrets", "/ansible/logs", "/ansible/cache", "/share"]

USER dragon
WORKDIR /ansible

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

LABEL "org.opencontainers.image.documentation"="https://docs.osism.de" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-image-ceph-ansible" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
