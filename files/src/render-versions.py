import os

import jinja2
import yaml

# get environment parameters

CEPH_VERSION = os.environ.get("CEPH_VERSION", "pacific")
VERSION = os.environ.get("VERSION", "latest")

# load versions files from release repository

with open("/release/%s/base.yml" % VERSION, "rb") as fp:
    versions = yaml.load(fp, Loader=yaml.FullLoader)

# prepare jinja2 environment

loader = jinja2.FileSystemLoader(searchpath="/src/templates/")
environment = jinja2.Environment(loader=loader)

# render versions.yml

template = environment.get_template("versions.yml.j2")

if VERSION == "latest":
    result = template.render({
      'ceph_ansible_version': CEPH_VERSION,
      'ceph_image_version': CEPH_VERSION,
      'cephclient_version': CEPH_VERSION
    })
else:
    with open("/release/%s/ceph.yml" % VERSION, "rb") as fp:
        versions_ceph = yaml.load(fp, Loader=yaml.FullLoader)

    result = template.render({
      'ceph_ansible_version': versions['manager_version'],
      'ceph_image_version': versions_ceph['docker_images']['ceph'],
      'cephclient_version': versions_ceph['docker_images']['cephclient']
    })

with open("/ansible/group_vars/all/versions.yml", "w+") as fp:
    fp.write(result)

# render motd

template = environment.get_template("motd.j2")
result = template.render({
  'manager_version': versions['manager_version']
})
with open("/etc/motd", "w+") as fp:
    fp.write(result)
