# SPDX-License-Identifier: Apache-2.0

# This script writes a list of all existing playbooks to /ansible/playbooks.yml.

from pathlib import Path

import yaml

PREFIX = "ceph"

result = {}

for path in Path("/ansible").glob(f"{PREFIX}-*.yml"):
    name = path.with_suffix("").name
    result[name] = PREFIX

with open("/ansible/playbooks.yml", "w+") as fp:
    fp.write(yaml.dump(result))
