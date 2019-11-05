import os

import jinja2
import yaml

# get environment parameters

CEPH_VERSION = os.environ.get("CEPH_VERSION", "luminous")
VERSION = os.environ.get("VERSION", "latest")

# load versions files from release repository

with open("/release/%s/base.yml" % VERSION, "rb") as fp:
    versions = yaml.load(fp, Loader=yaml.FullLoader)

with open("/release/%s/ceph-%s.yml" % (VERSION, CEPH_VERSION), "rb") as fp:
    versions_ceph = yaml.load(fp, Loader=yaml.FullLoader)

# prepare jinja2 environment

loader = jinja2.FileSystemLoader(searchpath="/src/templates/")
environment = jinja2.Environment(loader=loader)

# render versions.yml

template = environment.get_template("versions.yml.j2")
result = template.render({
  'ceph_ansible_version': versions_ceph['ceph_ansible_version'],
  'repository_version': versions['repository_version']
})
with open("/ansible/group_vars/all/versions.yml", "w+") as fp:
    fp.write(result)

# render motd

template = environment.get_template("motd.j2")
result = template.render({
  'ceph_ansible_version': versions_ceph['ceph_ansible_version'],
  'manager_version': versions['manager_version']
})
with open("/etc/motd", "w+") as fp:
    fp.write(result)
