# SPDX-License-Identifier: Apache-2.0

import os

import jinja2
import yaml

# get environment parameters

CEPH_VERSION = os.environ.get("CEPH_VERSION", "nautilus")
VERSION = os.environ.get("VERSION", "latest")

# load versions files from release repository

with open("/release/latest/base.yml", "rb") as fp:
    versions = yaml.load(fp, Loader=yaml.FullLoader)

with open(f"/release/latest/ceph-{CEPH_VERSION}.yml", "rb") as fp:
    ceph_versions = yaml.load(fp, Loader=yaml.FullLoader)

# prepare jinja2 environment

loader = jinja2.FileSystemLoader(searchpath="/src/templates/")
environment = jinja2.Environment(loader=loader)

# render requirements.txt

template = environment.get_template("requirements.txt.j2")
result = template.render(
    {
        "ansible_version": ceph_versions["ansible_version"],
        "ansible_core_version": ceph_versions["ansible_core_version"],
        "osism_projects": versions["osism_projects"],
        "version": VERSION,
    }
)
with open("/requirements.txt", "w+") as fp:
    fp.write(result)
