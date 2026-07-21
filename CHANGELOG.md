# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file was started on May 30, 2025. Changes prior to this date are not included in the CHANGELOG.

## [v0.20260615.0] - 2026-06-15

### Added
- Set require-min-compat-client on the OSD map to avoid Glance image deletion conflicts with Nova ephemeral clones (osism/container-image-ceph-ansible#690)

### Changed
- Clone the renamed osism/generics repository instead of the old cfg-generics path (osism/container-image-ceph-ansible#679)
- Add container, log, and admin-socket diagnostics around the mon quorum check in rolling_update to aid troubleshooting (osism/container-image-ceph-ansible#681)
- Automatically add opened issues and pull requests to the project board (osism/container-image-ceph-ansible#684)
- Drop obsolete osism-fqcn noqa workarounds on block constructs (osism/container-image-ceph-ansible#692)
- Use the ceph_key_info module to retrieve keys on squid instead of ceph_key with state: info (osism/container-image-ceph-ansible#695)

### Fixed
- Raise health_mon_check_retries to 10 to prevent rolling upgrade failures on slow-storage mon nodes (osism/container-image-ceph-ansible#681)
- Sort patch files before applying them to guarantee a deterministic, dependency-correct apply order (osism/container-image-ceph-ansible#686)

### Removed
- Drop redundant ara, docker, idna, and asn1crypto pins already covered by python-osism's dependencies (osism/container-image-ceph-ansible#689)
- Drop the unused vendored ansible-lint rules directory and its config reference (osism/container-image-ceph-ansible#693)
- Drop redundant paramiko and PyMySQL pins already covered by python-osism's dependencies (osism/container-image-ceph-ansible#697)

### Dependencies
- pymysql 1.1.2 → 1.1.3 (osism/container-image-ceph-ansible#682)
- requests 2.32.5 → 2.34.2 (osism/container-image-ceph-ansible#676, osism/container-image-ceph-ansible#687)
- cryptography 46.0.5 → 46.0.7 (osism/container-image-ceph-ansible#677)
- ghcr.io/astral-sh/uv 0.10.10 → 0.11.21 (osism/container-image-ceph-ansible#674, osism/container-image-ceph-ansible#691, osism/container-image-ceph-ansible#694, osism/container-image-ceph-ansible#696)

## [v0.20260322.0] - 2026-03-22

### Added
- Add CHANGELOG.md file to track notable changes (osism/container-image-ceph-ansible#675)

### Changed
- Drop ansible_version validation patch for squid (osism/container-image-ceph-ansible#670)

### Removed
- Remove defaults repository from container build (osism/container-image-ceph-ansible#672)
- Remove useless `/ansible/group_vars` directory creation (osism/container-image-ceph-ansible#673)

### Dependencies
- cryptography 46.0.4 → 46.0.5 (osism/container-image-ceph-ansible#669)
- ghcr.io/astral-sh/uv 0.9.27 → 0.10.10 (osism/container-image-ceph-ansible#665)
- ansible-pylibssh 1.3.0 → 1.4.0 (osism/container-image-ceph-ansible#671)

## [v0.20260129.0] - 2026-01-29

### Dependencies
- mitogen v0.3.22 → v0.3.39 (osism/container-image-ceph-ansible#664)

## [v0.20260128.0] - 2026-01-28

### Added
- Patch to fix group names in rolling_update.yml for stable-8.0 and stable-9.0, replacing hardcoded group names with configurable variables to fix issues with sub environments (osism/container-image-ceph-ansible#658)

### Dependencies
- ghcr.io/astral-sh/uv 0.9.16 → 0.9.27 (osism/container-image-ceph-ansible#657, osism/container-image-ceph-ansible#659, osism/container-image-ceph-ansible#660, osism/container-image-ceph-ansible#661)
- setuptools 80.9.0 → 80.10.2 (osism/container-image-ceph-ansible#662)
- cryptography 46.0.3 → 46.0.4 (osism/container-image-ceph-ansible#663)

## [v0.20251208.0] - 2025-12-08

### Dependencies
- ghcr.io/astral-sh/uv 0.9.13 → 0.9.16 (osism/container-image-ceph-ansible#656)

## [v0.20251130.0] - 2025-11-30

### Fixed
- Fix /ansible permissions to ensure WORKDIR is owned by dragon after Docker 29.0.0 change (osism/container-image-ceph-ansible#653)

### Dependencies
- ghcr.io/astral-sh/uv 0.9.7 → 0.9.13 (osism/container-image-ceph-ansible#652, osism/container-image-ceph-ansible#654, osism/container-image-ceph-ansible#655)

## [v0.20251101.0] - 2025-11-01

### Fixed
- Also stop RGW services with zone during ceph-purge-cluster for reef and squid (osism/container-image-ceph-ansible#646)

### Dependencies
- ansible-pylibssh 1.2.2 → 1.3.0 (osism/container-image-ceph-ansible#647)
- cryptography 46.0.1 → 46.0.3 (osism/container-image-ceph-ansible#643, osism/container-image-ceph-ansible#650)
- ghcr.io/astral-sh/uv 0.8.22 → 0.9.7 (osism/container-image-ceph-ansible#644, osism/container-image-ceph-ansible#645, osism/container-image-ceph-ansible#649, osism/container-image-ceph-ansible#651)
- idna 3.10 → 3.11 (osism/container-image-ceph-ansible#648)
- paramiko 3.5.1 → 4.0.0 (osism/container-image-ceph-ansible#627)

## [v0.20250927.0] - 2025-09-27

### Dependencies
- ghcr.io/astral-sh/uv 0.8.19 → 0.8.22 (osism/container-image-ceph-ansible#640)
- pyyaml 6.0.2 → 6.0.3 (osism/container-image-ceph-ansible#642)

## [v0.20250920.0] - 2025-09-20

### Dependencies
- ghcr.io/astral-sh/uv 0.8.17 → 0.8.19 (osism/container-image-ceph-ansible#638, osism/container-image-ceph-ansible#639)
- cryptography 45.0.7 → 46.0.1 (osism/container-image-ceph-ansible#636)

## [v0.20250915.0] - 2025-09-15

### Added
- Container image signing with cosign in Zuul CI pipeline (osism/container-image-ceph-ansible#624)

### Fixed
- Image signing script logic for version and repository handling (osism/container-image-ceph-ansible#626)
- Ceph RGW rolling upgrade by stopping additional service name pattern without zone prefix (osism/container-image-ceph-ansible#635)

### Dependencies
- ghcr.io/astral-sh/uv 0.7.19 → 0.8.17 (osism/container-image-ceph-ansible#623, osism/container-image-ceph-ansible#625, osism/container-image-ceph-ansible#632, osism/container-image-ceph-ansible#634)
- cryptography 45.0.5 → 45.0.7 (osism/container-image-ceph-ansible#628, osism/container-image-ceph-ansible#633)
- pymysql 1.1.1 → 1.1.2 (osism/container-image-ceph-ansible#631)
- requests 2.32.4 → 2.32.5 (osism/container-image-ceph-ansible#630)

## [v0.20250711.0] - 2025-07-11

No changes. This release is identical to v0.20250704.0.

## [v0.20250704.0] - 2025-07-04

### Dependencies
- ghcr.io/astral-sh/uv 0.7.8 → 0.7.19 (osism/container-image-ceph-ansible#612, osism/container-image-ceph-ansible#615, osism/container-image-ceph-ansible#616, osism/container-image-ceph-ansible#619, osism/container-image-ceph-ansible#620, osism/container-image-ceph-ansible#621)
- requests 2.32.3 → 2.32.4 (osism/container-image-ceph-ansible#617)
- cryptography 45.0.3 → 45.0.5 (osism/container-image-ceph-ansible#618, osism/container-image-ceph-ansible#622)

## [v0.20250530.0] - 2025-05-30

### Added
- Initial public release of the ceph-ansible container image with Dockerfile, Ansible playbooks, configuration files, build scripts, and patches for ceph-ansible stable-3.2 (osism/container-image-ceph-ansible#3)
- Playbook to apply Ceph roles for a typical HCI environment (osism/container-image-ceph-ansible#6)
- Docker package to Python requirements for docker purge infrastructure playbook (osism/container-image-ceph-ansible#7)
- Travis CI tag support for versioned builds (osism/container-image-ceph-ansible#4)
- Support for Ceph Nautilus (stable-4.0) including image configuration and patches (osism/container-image-ceph-ansible#11)
- Support for master/latest Ceph builds with dedicated image configuration and patches (osism/container-image-ceph-ansible#12)
- Ceph UID 64045 defaults configuration instead of relying on patch (osism/container-image-ceph-ansible#18)
- OCI-compliant image labels (`org.opencontainers.image.*`) to Dockerfile and build script (osism/container-image-ceph-ansible#20)
- Travis CI deploy stage for pushing images (osism/container-image-ceph-ansible#23)
- CEPH_VERSION tag pushing in build pipeline (osism/container-image-ceph-ansible#24)
- Deployment tests for mons, mgrs, and mdss services (osism/container-image-ceph-ansible#28) (osism/container-image-ceph-ansible#29)
- OCI container image labels for documentation, license, source, title, URL, and vendor (osism/container-image-ceph-ansible#31)
- Copy of site.yml playbook into container image (osism/container-image-ceph-ansible#34)
- Copy of dashboard.yml into container image when available (osism/container-image-ceph-ansible#37)
- Release-specific playbook directories for luminous, nautilus, and master (osism/container-image-ceph-ansible#33)
- Ceph Octopus release support with playbooks and image configuration (osism/container-image-ceph-ansible#40)
- Playbook to purge a single storage node (osism/container-image-ceph-ansible#43)
- `grafana_server_group_name` parameter to defaults (osism/container-image-ceph-ansible#44)
- Install openssh-client in container image (osism/container-image-ceph-ansible#39)
- GitHub Actions workflows for PR labeling, Docker image building, and syntax checking (osism/container-image-ceph-ansible#54) (osism/container-image-ceph-ansible#72)
- NETBOX_TOKEN environment variable support via Docker secrets (osism/container-image-ceph-ansible#59)
- Netbox inventory file (99-netbox.yml) for dynamic inventory (osism/container-image-ceph-ansible#61)
- Netbox and ansible.netcommon Ansible collections (osism/container-image-ceph-ansible#62) (osism/container-image-ceph-ansible#74)
- Missing defaults for dashboard_admin_password and grafana_admin_password (osism/container-image-ceph-ansible#67)
- ceph_image_version variable for image version management (osism/container-image-ceph-ansible#73)
- Patch to set become: false for generate-monitor-initial-keyring task (osism/container-image-ceph-ansible#76)
- pynetbox dependency (osism/container-image-ceph-ansible#82)
- ceph-crash playbook for nautilus, master, and octopus (osism/container-image-ceph-ansible#94) (osism/container-image-ceph-ansible#95)
- Script to handle inventory overwrites (osism/container-image-ceph-ansible#99)
- Missing callback and filter plugins to container build (osism/container-image-ceph-ansible#92)
- Luminous and octopus builds to CI (osism/container-image-ceph-ansible#84) (osism/container-image-ceph-ansible#96)
- Support for Ceph Pacific version with playbooks, patches, and build configuration (osism/container-image-ceph-ansible#111)
- Manual workflow triggering for CI builds (osism/container-image-ceph-ansible#121)
- Interface volume and entrypoint script for syncing Ansible files (osism/container-image-ceph-ansible#123)
- "Release docker image" GitHub Actions workflow
- Ceph version resolution from release repository for release builds
- cephclient version to versions template
- Enable ceph-crash role in testbed playbooks
- Install python-osism in container build (osism/container-image-ceph-ansible#150)
- Install celery[redis] and ansible-runner as dependencies (osism/container-image-ceph-ansible#151)
- Install hiredis for improved Redis performance (osism/container-image-ceph-ansible#154)
- Copy versions.yml to /interface directory (osism/container-image-ceph-ansible#155)
- Add ceph_version field to versions.yml.j2 (osism/container-image-ceph-ansible#156)
- Re-enable nautilus build in CI (osism/container-image-ceph-ansible#158)
- ceph-bootstrap-dashboard playbook (osism/container-image-ceph-ansible#190)
- pottery Python dependency
- Renovate configuration for automated dependency updates
- Install ansible-pylibssh for libssh support (osism/container-image-ceph-ansible#192)
- ansible-lint rules for attribute order and FQCN checks (osism/container-image-ceph-ansible#205)
- GitHub Actions workflow for ansible syntax checking (osism/container-image-ceph-ansible#205)
- Quincy Ceph release support with playbooks, patches, and ansible-core packaging (osism/container-image-ceph-ansible#212)
- Ansible collections required by Quincy and later releases (ansible.utils, community.general, ansible.posix, ansible-config_template) (osism/container-image-ceph-ansible#216)
- SBOM generation in build and release CI workflows (osism/container-image-ceph-ansible#219)
- `de.osism.release.ceph` label to container image (osism/container-image-ceph-ansible#220)
- Mitogen Ansible plugin re-added to container image (osism/container-image-ceph-ansible#223)
- Custom purge playbooks for pacific and quincy Ceph versions (osism/container-image-ceph-ansible#227)
- ceph-infra playbook for deploying logrotate configuration (osism/container-image-ceph-ansible#252)
- ceph-infra role to the ceph-base playbook (osism/container-image-ceph-ansible#253)
- ceph-validate playbook (osism/container-image-ceph-ansible#254)
- Playbook list rendering script that writes all existing playbooks to /ansible/playbooks.yml (osism/container-image-ceph-ansible#261)
- flake8 syntax check via Zuul (osism/container-image-ceph-ansible#271)
- hadolint check via Zuul (osism/container-image-ceph-ansible#273)
- Mock roles and modules for ansible-lint (osism/container-image-ceph-ansible#275)
- Support for sub environments via `SUB` variable in run script (osism/container-image-ceph-ansible#279)
- ceph-ceph playbook to deploy all Ceph services in a single step (osism/container-image-ceph-ansible#293)
- Patch to ignore Ansible version check in ceph-validate (osism/container-image-ceph-ansible#296)
- ARA configuration file with default labels, ignored facts, files, and arguments (osism/container-image-ceph-ansible#297)
- Periodic-daily jobs in Zuul for ansible-lint, flake8, hadolint, and yamllint (osism/container-image-ceph-ansible#305)
- ansible-vault.py script to retrieve vault password from Redis (osism/container-image-ceph-ansible#334)
- Fernet encryption support to ansible-vault.py script (osism/container-image-ceph-ansible#338)
- json_stats callback plugin for JSON summary stats output on STDERR (osism/container-image-ceph-ansible#342)
- Zuul build & push jobs for container images
- Support for `/inventory/ansible/ansible.cfg` configuration path (osism/container-image-ceph-ansible#359)
- Release jobs to the Zuul tag pipeline (osism/container-image-ceph-ansible#361)
- Ceph pools play for managing ceph pools independent of the ceph-osds play (osism/container-image-ceph-ansible#388)
- `change-osism.sh` script to install a different python-osism version in a running inventory reconciler service (osism/container-image-ceph-ansible#391)
- Configurable Ceph dashboard port and address via `ceph_dashboard_port` and `ceph_dashboard_addr` parameters (osism/container-image-ceph-ansible#397)
- Missing `ceph_dashboard_password` parameter for dashboard bootstrap playbook (osism/container-image-ceph-ansible#398)
- `ceph-pull-image` play for pulling Ceph container images (osism/container-image-ceph-ansible#405)
- `set -e` to run script for fail-fast behavior (osism/container-image-ceph-ansible#408)
- python-black job to Zuul CI pipeline (osism/container-image-ceph-ansible#411)
- Zuul semaphore for ceph-ansible quincy push job (osism/container-image-ceph-ansible#432)
- Clean up pycache directories and pyc files during container build using pyclean (osism/container-image-ceph-ansible#418)
- Ceph LVM volume configuration and creation playbooks (`ceph-configure-lvm-volumes`, `ceph-create-lvm-devices`) from osism/ansible-playbooks (osism/container-image-ceph-ansible#437)
- Copy templates directory into container image (osism/container-image-ceph-ansible#438)
- Support for device links in the LVM2 configure playbooks (osism/container-image-ceph-ansible#439)
- Support for `disk/by-id` device paths in Ceph LVM plays (osism/container-image-ceph-ansible#444)
- Support for partitions as OSDs in Ceph LVM plays (osism/container-image-ceph-ansible#447)
- Reef release support with playbooks, CI/CD jobs, and build configuration (osism/container-image-ceph-ansible#453)
- Support for custom playbooks in the run script (osism/container-image-ceph-ansible#458)
- Reef patches for ceph-uid 64045, UTF-8 character removal, and ansible version validation bypass (osism/container-image-ceph-ansible#456)
- Reef patch to skip ceph-exporter service upgrade (osism/container-image-ceph-ansible#457)
- `ceph_serial` parameter to all relevant plays for controlling play serialization (osism/container-image-ceph-ansible#461)
- Parameters to skip and throttle service restarts via ceph-handler patches (osism/container-image-ceph-ansible#469)
- Validation check for exclusive usage of `ceph_db_wal_devices` (osism/container-image-ceph-ansible#449)
- Configurable Ansible strategy via `osism_strategy` parameter in all plays (osism/container-image-ceph-ansible#476)
- Ceph dashboard standby behaviour and status code configurable (osism/container-image-ceph-ansible#481)
- Check for locks in the configuration repository (osism/container-image-ceph-ansible#491) (osism/container-image-ceph-ansible#492)
- Generate and push SBOM via Zuul CI (osism/container-image-ceph-ansible#511) (osism/container-image-ceph-ansible#512) (osism/container-image-ceph-ansible#513) (osism/container-image-ceph-ansible#514)
- Play to add new OSDs (`ceph-add-osds`) for use with `-l` and `--skip-tags wait_all_osds_up` parameters (osism/container-image-ceph-ansible#530)
- Plays to manage storage/OSD nodes (`ceph-disable-storage-node` and `ceph-enable-storage-node`) for adding/removing noout flags (osism/container-image-ceph-ansible#531)
- `openstack_config.yml` tasks file from ceph/ceph-ansible repository (osism/container-image-ceph-ansible#552)
- Check mode support in the `ceph-create-lvm-devices` play (osism/container-image-ceph-ansible#529)
- Symlink /ansible/ceph-upgrade.yml → /ansible/ceph-rolling_update.yml (osism/container-image-ceph-ansible#584)
- Ceph Squid release support with playbooks, CI/CD jobs, and build configuration (osism/container-image-ceph-ansible#586)

### Changed
- Use tar without verbose flag (`-v`) in Dockerfile to reduce build output (osism/container-image-ceph-ansible#3)
- Extended purge cluster cleanup patch to skip docker service removal, package removal, and tolerate remaining containers/images (osism/container-image-ceph-ansible#5)
- HCI playbook split into separate plays so mon role runs with `serial: 1` (osism/container-image-ceph-ansible#8)
- Cleaned up stable-3.2 patch files by removing unnecessary git diff headers (osism/container-image-ceph-ansible#10)
- Renamed `.placeholder` files to `.gitkeep` (osism/container-image-ceph-ansible#22)
- Updated README with project description (osism/container-image-ceph-ansible#26)
- Default Docker registry from index.docker.io to quay.io (osism/container-image-ceph-ansible#30)
- Renamed `ceph-docker-common` role to `ceph-container-common` in all playbooks (osism/container-image-ceph-ansible#28)
- Renamed `ceph-env-hci.yml` playbook to `ceph-testbed.yml` (osism/container-image-ceph-ansible#38)
- Tests now abort on first failure (osism/container-image-ceph-ansible#32)
- Synced test inventory with updated group structure (osism/container-image-ceph-ansible#36)
- Cleaned up stable-4.0 patch files (osism/container-image-ceph-ansible#27)
- Use Ubuntu Focal (20.04) base image for master/nautilus/octopus builds (osism/container-image-ceph-ansible#45)
- Change default Ceph version from luminous to nautilus (osism/container-image-ceph-ansible#49)
- Update documentation URL to docs.osism.de (osism/container-image-ceph-ansible#47)
- Remove license note from README (osism/container-image-ceph-ansible#48)
- Clean up mitogen directory by removing tests, docs, and CI files (osism/container-image-ceph-ansible#52)
- Enable Travis CI tag-based deployments (osism/container-image-ceph-ansible#50) (osism/container-image-ceph-ansible#51)
- Use /ansible/inventory as inventory directory with rsync from configuration (osism/container-image-ceph-ansible#57)
- Sync /ansible/group_vars/ with /ansible/inventory/group_vars/ at runtime (osism/container-image-ceph-ansible#65)
- Switch from Travis CI to GitHub Actions for CI/CD (osism/container-image-ceph-ansible#71) (osism/container-image-ceph-ansible#72)
- Use Docker buildx for image builds (osism/container-image-ceph-ansible#79)
- Rename repository from docker-ceph-ansible to docker-image-ceph-ansible (osism/container-image-ceph-ansible#75)
- Cleanup GitHub workflows and README (osism/container-image-ceph-ansible#69) (osism/container-image-ceph-ansible#70)
- Move hadolint and yamllint configuration files to project root (osism/container-image-ceph-ansible#80) (osism/container-image-ceph-ansible#81)
- Switch hadolint action to brpaz/hadolint-action@v1.2.1 (osism/container-image-ceph-ansible#80)
- Set useful defaults: docker registry to quay.io, OSD bluestore/lvm, manager modules, RGW port (osism/container-image-ceph-ansible#86)
- Disable prometheus/grafana dashboard by default (osism/container-image-ceph-ansible#93)
- Use Ubuntu 18.04 for luminous builds (osism/container-image-ceph-ansible#87)
- Rebuild Docker image more frequently (hourly 8-22) (osism/container-image-ceph-ansible#90)
- Merge inventory files and keep generics inventory separate (osism/container-image-ceph-ansible#101) (osism/container-image-ceph-ansible#103)
- Handle :children sections in inventory overwrite script (osism/container-image-ceph-ansible#105)
- Only build octopus in CI, drop luminous and nautilus (osism/container-image-ceph-ansible#110)
- Upgrade pip during container build (osism/container-image-ceph-ansible#98)
- Copy module_utils directory during build if it exists (osism/container-image-ceph-ansible#113)
- Synchronize /ansible/inventory only if the directory is writable (osism/container-image-ceph-ansible#114)
- Only remove 99-netbox.yml if /ansible/inventory is writable and NETBOX_TOKEN secret is missing (osism/container-image-ceph-ansible#115)
- Rename repository from docker-image-ceph-ansible to container-image-ceph-ansible, Dockerfile to Containerfile (osism/container-image-ceph-ansible#117)
- Use the ansible-defaults repository for default variables instead of bundled files (osism/container-image-ceph-ansible#120)
- Company name from "Betacloud Solutions GmbH" to "OSISM GmbH" (osism/container-image-ceph-ansible#125)
- Refactored Containerfile for release 1.0.0: use release repository for version management, pin Python dependencies, add jq package, update documentation URLs
- Use commit hash as internal docker tag instead of repository-prefixed tags
- Refactored version rendering to support both latest and release builds
- Updated purge-cluster-cleanup patches for all Ceph versions (master, stable-5.0, stable-6.0)
- Replaced inventory file download via ADD with copy from cloned generics repository
- Improve handling of Ansible version pinning in requirements template
- Switch container build tooling from docker buildx to buildah
- Update CI branch references from master to main
- Push container images only when running in upstream repository (osism/container-image-ceph-ansible#152)
- Rename "docker" to "container" in CI workflow names and job IDs (osism/container-image-ceph-ansible#157)
- Restrict CI branch builds to main branch only (osism/container-image-ceph-ansible#159)
- Re-enable fact gathering in pacific playbooks (osism/container-image-ceph-ansible#153)
- Disable fail-fast for container image builds to see all build results (osism/container-image-ceph-ansible#161)
- Pin all versions in requirements.txt.j2 template (osism/container-image-ceph-ansible#173)
- Use `pip install --no-cache-dir` to avoid cache directory in container image (osism/container-image-ceph-ansible#172)
- Push release images to osism/release repository path
- Use osism/renovate-config presets for Renovate configuration
- Use Ansible FQCNs in playbooks (osism/container-image-ceph-ansible#192)
- Get versions for defaults/generics/playbooks from ceph.yml instead of base.yml (osism/container-image-ceph-ansible#203)
- Pin ansible.netcommon collection to 2.5.0 to avoid ipaddr migration issue (osism/container-image-ceph-ansible#201)
- Rename `ceph-testbed` playbook to `ceph-base` and remove ceph-mds role from it across all releases (osism/container-image-ceph-ansible#214)
- Upgrade base image from Ubuntu 20.04 to Ubuntu 22.04 (osism/container-image-ceph-ansible#215)
- Install osism package from PyPI instead of cloning the git repository (osism/container-image-ceph-ansible#226)
- Make plugin directory copy commands conditional in Containerfile to support quincy release structure (osism/container-image-ceph-ansible#212)
- Reduced container image rebuild schedule to once daily (osism/container-image-ceph-ansible#230)
- Validate playbook now runs on all ceph hosts instead of localhost (osism/container-image-ceph-ansible#255)
- Allow environment variable overwrites in run.sh (osism/container-image-ceph-ansible#274)
- Install ara without server extras instead of ara[server] (osism/container-image-ceph-ansible#262)
- Transfer ansible-lint check from GitHub Actions to Zuul (osism/container-image-ceph-ansible#267)
- Transfer yamllint check from GitHub Actions to Zuul (osism/container-image-ceph-ansible#270)
- Transfer hadolint check from GitHub Actions to Zuul (osism/container-image-ceph-ansible#273)
- Add merge-mode squash-merge to Zuul configuration (osism/container-image-ceph-ansible#268)
- Exclude upstream ceph-ansible purge and bootstrap-dashboard playbooks from ansible-lint (osism/container-image-ceph-ansible#276) (osism/container-image-ceph-ansible#282)
- Make Ceph host group names configurable via variables with defaults across all playbook versions (osism/container-image-ceph-ansible#284) (osism/container-image-ceph-ansible#287) (osism/container-image-ceph-ansible#288)
- Use roles instead of include_role in ceph-ceph playbook (osism/container-image-ceph-ansible#294)
- Use ansible-core for all ceph-ansible releases (osism/container-image-ceph-ansible#295)
- Use hosts.yml as inventory file instead of inventory directory (osism/container-image-ceph-ansible#325)
- Enable var-spacing ansible-lint rule and fix spacing in playbooks (osism/container-image-ceph-ansible#326)
- Use osism version from osism/release instead of hardcoded value (osism/container-image-ceph-ansible#314)
- Add version 4.3.0 compatibility to still install ansible instead of ansible-core (osism/container-image-ceph-ansible#315)
- Make vault password file path configurable via VAULT environment variable (osism/container-image-ceph-ansible#334)
- Decode ansible_vault_password bytes to UTF-8 string (osism/container-image-ceph-ansible#335)
- Hadolint: Refactor rules and fix code issues (osism/container-image-ceph-ansible#348)
- Refactored Containerfile to use heredocs for better readability (osism/container-image-ceph-ansible#354)
- Show push logs in Zuul build pipeline (osism/container-image-ceph-ansible#355)
- Renamed `docker_registry` variable to `registry` in build playbook (osism/container-image-ceph-ansible#356)
- Switched defaults repository from `osism/ansible-defaults` to `osism/defaults` (osism/container-image-ceph-ansible#358)
- Set default value of `version_ceph` to `master` in build playbook (osism/container-image-ceph-ansible#365)
- Switch base image to python:3.11-slim (osism/container-image-ceph-ansible#369)
- Install missing packages (iputils-ping, procps) after base image change (osism/container-image-ceph-ansible#370)
- Use multi-stage build for the container image (osism/container-image-ceph-ansible#389)
- Revert removal of pacific support for Ceph upgrade tests in testbed (osism/container-image-ceph-ansible#393)
- Install osism.commons collection for still_alive callback plugin (osism/container-image-ceph-ansible#422)
- Add SPDX license identifier to Python files (osism/container-image-ceph-ansible#423)
- Use Debian Bookworm as base image (osism/container-image-ceph-ansible#419)
- Add scheduled Zuul build at midnight (osism/container-image-ceph-ansible#425)
- Unified `change-osism.sh` into a single `change.sh` script supporting both osism and operations targets (osism/container-image-ceph-ansible#435)
- Default Ceph version changed from master to quincy in build playbook and test script (osism/container-image-ceph-ansible#436)
- Simplified container image tagging logic by removing master/latest special case (osism/container-image-ceph-ansible#436)
- Updated release repository URLs from master to main branch (osism/container-image-ceph-ansible#436)
- Updated ansible-lint skip list configuration (osism/container-image-ceph-ansible#437)
- Remove inline description comments from the Ceph LVM2 plays (osism/container-image-ceph-ansible#441)
- Remove `serial: 1` from the Ceph LVM2 plays (osism/container-image-ceph-ansible#451)
- Update container image documentation and URL labels (osism/container-image-ceph-ansible#452)
- Moved LVM2 plays from version-specific directories to shared location (osism/container-image-ceph-ansible#454)
- Restored `serial: 1` in ceph LVM2 plays for reliability (osism/container-image-ceph-ansible#455)
- Replaced osism.github.io with osism.tech in documentation URL (osism/container-image-ceph-ansible#459)
- Updated documentation URL from `https://osism.tech/docs/intro` to `https://osism.tech/docs/` (osism/container-image-ceph-ansible#463)
- Set `openstack_config = true` in ceph-pools playbook to enable key generation (osism/container-image-ceph-ansible#464)
- Throttle OSD restarts by default with throttle=1 (osism/container-image-ceph-ansible#470)
- Throttle MON restarts by default with throttle=1 (osism/container-image-ceph-ansible#471)
- Use `COPY --link` in Containerfile for improved build layer caching (osism/container-image-ceph-ansible#475)
- Avoid restarts of other services in single service plays (osism/container-image-ceph-ansible#477)
- Use ceph-mgr host group in the ceph-bootstrap-dashboard play (osism/container-image-ceph-ansible#499)
- Ignore all Python UserWarnings to suppress CryptographyDeprecationWarning (osism/container-image-ceph-ansible#507)
- Use `ENV key=value` syntax in Containerfile (osism/container-image-ceph-ansible#501)
- Patch `container_binary` to support podman on Ubuntu/Debian instead of only RedHat/Fedora (osism/container-image-ceph-ansible#518)
- Refactored `ceph-ceph` play to run roles per host group with selective handler restarts for improved deploy time (osism/container-image-ceph-ansible#527)
- Use configurable `osd_group_name` instead of hardcoded `ceph-osd` group name in LVM plays (osism/container-image-ceph-ansible#534)
- Noout flag tasks on OSDs now correctly report as changed (osism/container-image-ceph-ansible#532)
- Improved hadolint configuration with rule documentation links and removed inline ignores (osism/container-image-ceph-ansible#539)
- Install setuptools as dependency for ansible-config_template (osism/container-image-ceph-ansible#541)
- Use uv instead of pip for Python package installation (osism/container-image-ceph-ansible#572)
- Use dtrack.osism.tech as Dependency-Track server URL (osism/container-image-ceph-ansible#556)
- Only checkout specific tags when not building latest (osism/container-image-ceph-ansible#575)
- Use openstack/ansible-config_template from github.com mirror instead of opendev.org (osism/container-image-ceph-ansible#596)
- Refresh Zuul secrets (osism/container-image-ceph-ansible#598)
- Use image cache for container builds (osism/container-image-ceph-ansible#599)
- Decouple the image build from the old OSISM X.Y.Z release scheme (osism/container-image-ceph-ansible#585)
- Use latest in build play (osism/container-image-ceph-ansible#610)

### Fixed
- Missing `fi` in push script (osism/container-image-ceph-ansible#13)
- purge-cluster-cleanup.patch for master to match upstream changes (osism/container-image-ceph-ansible#14) (osism/container-image-ceph-ansible#15) (osism/container-image-ceph-ansible#17)
- purge-cluster-cleanup.patch for stable-4.0 to match upstream changes (osism/container-image-ceph-ansible#15) (osism/container-image-ceph-ansible#16)
- Dockerfile to retain requirements.txt needed by osism/manager image (osism/container-image-ceph-ansible#19)
- Missing `$VERSION` in docker push command (osism/container-image-ceph-ansible#25)
- Handle renamed site-container.yml.sample in addition to site-docker.yml.sample (osism/container-image-ceph-ansible#42)
- Fix ceph-nfs-mkdir.patch for stable-3.2 (osism/container-image-ceph-ansible#60)
- Fix secrets.sh failing when NETBOX_TOKEN file does not exist (osism/container-image-ceph-ansible#64)
- Fix always-use-ceph-uid-64045.patch for multiple Ceph versions (osism/container-image-ceph-ansible#66)
- Fix purge-cluster-cleanup.patch for stable-4.0 (osism/container-image-ceph-ansible#83) (osism/container-image-ceph-ansible#107)
- Fix purge-cluster-cleanup.patch for stable-5.0 (osism/container-image-ceph-ansible#108)
- Fix always-use-ceph-uid-64045.patch for stable-5.0 (osism/container-image-ceph-ansible#109)
- Fix ceph-fetch-keys playbook by adding missing ceph-defaults and ceph-facts roles (osism/container-image-ceph-ansible#91)
- Fix typo in inventory merge path (osism/container-image-ceph-ansible#102)
- Fix indentation in handle-inventory-overwrite.py (osism/container-image-ceph-ansible#104)
- Disable ARA for luminous due to incompatible Ansible version (osism/container-image-ceph-ansible#89)
- ceph-facts playbook now applies the ceph-facts role in addition to gathering facts (osism/container-image-ceph-ansible#118)
- Hadolint warning DL3046 by adding `-l` flag to useradd (osism/container-image-ceph-ansible#124)
- Docker image push tags for release and latest versions
- Removed erroneous `.yml` extension in release version scripts
- Wrong variable name in version rendering (`ceph_manager_version` → `ceph_image_version`)
- Missing quotes in versions template
- Versions template to use correct variable names
- Add missing ceph_dashboard_username variable to ceph-bootstrap-dashboard playbook (osism/container-image-ceph-ansible#192)
- Add missing short revision ID step in release workflow for SBOM generation (osism/container-image-ceph-ansible#221)
- Added ignore_errors for container image removal and removed docker data cleanup in purge playbook (osism/container-image-ceph-ansible#228)
- Add missing task names in ceph-facts playbooks for master, octopus, pacific, and quincy releases (osism/container-image-ceph-ansible#281)
- Fix flake8 issues in callback plugin and inventory handler (osism/container-image-ceph-ansible#378)
- Revert ansible-config_template to v2.0.0 due to broken cluster configuration generation (osism/container-image-ceph-ansible#420)
- Fix wrong position of `)` in ceph-configure-lvm-volumes play (osism/container-image-ceph-ansible#442)
- Fix check condition for block + WAL task in ceph-configure-lvm-volumes play (osism/container-image-ceph-ansible#445)
- Handle missing partitions attribute when using a partition as OSD (osism/container-image-ceph-ansible#448)
- Add missing defined-checks for DB/WAL LV sizes in ceph-create-lvm-devices play (osism/container-image-ceph-ansible#450)
- Updated do-not-upgrade-ceph-exporter patch to apply correctly against latest upstream (osism/container-image-ceph-ansible#460)
- Avoid `ceph_db_devices`/`ceph_wal_devices` undefined errors in LVM volume configuration (osism/container-image-ceph-ansible#497)
- Fix group names in shrink plays (osism/container-image-ceph-ansible#503)
- Fix duplicate `when` conditions in ceph-handler-skip-and-throttle patch (osism/container-image-ceph-ansible#506)
- Fix `FROM ... AS` casing in Containerfile (osism/container-image-ceph-ansible#502)
- `ceph-ceph` play now executes roles per host group instead of a single group, fixing non-HCI environments (osism/container-image-ceph-ansible#526)
- Syntax issue in `container-binary.patch` (osism/container-image-ceph-ansible#519)
- Wrong path to tasks file in `ceph-pools` play (osism/container-image-ceph-ansible#552)
- Wrong path to the inventory directory in `run.sh` (osism/container-image-ceph-ansible#544)
- Fix wrong version in build play (osism/container-image-ceph-ansible#611)
- Fix "osism/ceph-ansible:quid not found" in sbom part of the build play (osism/container-image-ceph-ansible#613)
- Fix "grep: /release/v0.20250530.0/ceph-reef.yml: No such file or directory" (osism/container-image-ceph-ansible#614)

### Removed
- AWX playbooks (osism/container-image-ceph-ansible#53)
- Travis CI integration (osism/container-image-ceph-ansible#71)
- Trivy vulnerability scanner from CI due to API rate limiting (osism/container-image-ceph-ansible#68)
- Sync with master repository workflow (osism/container-image-ceph-ansible#70)
- Mitogen plugin (osism/container-image-ceph-ansible#85) (osism/container-image-ceph-ansible#374)
- gnupg-agent from Dockerfile (osism/container-image-ceph-ansible#88)
- generate-monitor-initial-keyring-become-false.patch for stable-4.0 and stable-5.0 (osism/container-image-ceph-ansible#98)
- Stop removing /src directory during cleanup to preserve scripts (osism/container-image-ceph-ansible#100)
- PR Labeler workflow and configuration (osism/container-image-ceph-ansible#122)
- Bundled default variable files (defaults.yml, images-*.yml, images.yml) in favor of ansible-defaults repository (osism/container-image-ceph-ansible#120)
- `repository_version` from version templates
- `ceph_ansible_version` from motd template
- OCI labels from Containerfile (moved to build script)
- Purge-cluster-cleanup.patch files (Docker removal bypass now handled via remove_docker tag)
- Netbox inventory plugin handling (osism/container-image-ceph-ansible#148)
- Purge playbooks from container image (osism/container-image-ceph-ansible#160)
- Nautilus Ceph version from CI build matrix (osism/container-image-ceph-ansible#180)
- Octopus release from CI build matrix (osism/container-image-ceph-ansible#217)
- Old Ceph releases luminous and nautilus including all playbooks and defaults (osism/container-image-ceph-ansible#278)
- ansible-runner from requirements, installed via python-osism when needed (osism/container-image-ceph-ansible#285)
- Custom ansible-lint rules directory (osism/container-image-ceph-ansible#286)
- hiredis package, already installed by osism package (osism/container-image-ceph-ansible#316)
- pynetbox package, already installed by osism package (osism/container-image-ceph-ansible#317)
- Old octopus playbooks and files (osism/container-image-ceph-ansible#344)
- GitHub Actions build & push workflows, replaced by Zuul
- build.sh and push.sh scripts, replaced by Zuul playbooks
- celery[redis] and redis dependencies (osism/container-image-ceph-ansible#342)
- Pacific Ceph version support (osism/container-image-ceph-ansible#368) (osism/container-image-ceph-ansible#417)
- ruamel.yaml dependency from requirements (osism/container-image-ceph-ansible#395)
- json_stats Ansible callback plugin (osism/container-image-ceph-ansible#403) (osism/container-image-ceph-ansible#409)
- vim-tiny from container image (osism/container-image-ceph-ansible#251)
- proxmoxer package (osism/container-image-ceph-ansible#247)
- Old master playbooks, patches, and default files for master/latest container image builds (osism/container-image-ceph-ansible#436)
- Old patch files for stable-3.2, stable-4.0, stable-5.0, and stable-6.0 (osism/container-image-ceph-ansible#440)
- Old release references (master, octopus, pacific) from ansible-lint configuration (osism/container-image-ceph-ansible#453)
- ceph-iscsigws play, iSCSI gateway has been in maintenance since November 2022 (osism/container-image-ceph-ansible#462)
- `container_binary` fact auto-detection task, now set via osism/defaults (osism/container-image-ceph-ansible#516)
- Release notes, now managed in central osism/release repository (osism/container-image-ceph-ansible#487)

### Dependencies
- netaddr added as new requirement (osism/container-image-ceph-ansible#28)
- mitogen 0.2.8 → 0.2.9 (osism/container-image-ceph-ansible#41)
- actions/checkout v2 → v3 (osism/container-image-ceph-ansible#166)
- actions/setup-python v2 → v4 (osism/container-image-ceph-ansible#167) (osism/container-image-ceph-ansible#198)
- ansible-config_template 1.2.1 → 2.1.0 (osism/container-image-ceph-ansible#218) (osism/container-image-ceph-ansible#396)
- ansible-pylibssh 0.3.0 → 1.2.2 (osism/container-image-ceph-ansible#236) (osism/container-image-ceph-ansible#243) (osism/container-image-ceph-ansible#494) (osism/container-image-ceph-ansible#500)
- ansible-runner 2.1.2 → 2.3.1 (osism/container-image-ceph-ansible#183) (osism/container-image-ceph-ansible#237)
- ansible.netcommon 2.5.0 → 2.6.1 (osism/container-image-ceph-ansible#231)
- asn1crypto 1.4.0 → 1.5.1 (osism/container-image-ceph-ansible#178)
- brpaz/hadolint-action v1.2.1 → v1.5.0 (osism/container-image-ceph-ansible#165)
- celery 5.2.0 → 5.2.7 (osism/container-image-ceph-ansible#191) (osism/container-image-ceph-ansible#233)
- cryptography 36.0.1 → 45.0.3 (osism/container-image-ceph-ansible#179) (osism/container-image-ceph-ansible#246) (osism/container-image-ceph-ansible#290) (osism/container-image-ceph-ansible#301) (osism/container-image-ceph-ansible#307) (osism/container-image-ceph-ansible#332) (osism/container-image-ceph-ansible#336) (osism/container-image-ceph-ansible#347) (osism/container-image-ceph-ansible#360) (osism/container-image-ceph-ansible#372) (osism/container-image-ceph-ansible#386) (osism/container-image-ceph-ansible#401) (osism/container-image-ceph-ansible#402) (osism/container-image-ceph-ansible#426) (osism/container-image-ceph-ansible#427) (osism/container-image-ceph-ansible#428) (osism/container-image-ceph-ansible#431) (osism/container-image-ceph-ansible#434) (osism/container-image-ceph-ansible#478) (osism/container-image-ceph-ansible#480) (osism/container-image-ceph-ansible#493) (osism/container-image-ceph-ansible#505) (osism/container-image-ceph-ansible#521) (osism/container-image-ceph-ansible#533) (osism/container-image-ceph-ansible#537) (osism/container-image-ceph-ansible#558) (osism/container-image-ceph-ansible#561) (osism/container-image-ceph-ansible#592) (osism/container-image-ceph-ansible#603) (osism/container-image-ceph-ansible#604) (osism/container-image-ceph-ansible#609)
- docker 5.0.3 → 7.1.0 (osism/container-image-ceph-ansible#245) (osism/container-image-ceph-ansible#320) (osism/container-image-ceph-ansible#324) (osism/container-image-ceph-ansible#337) (osism/container-image-ceph-ansible#412) (osism/container-image-ceph-ansible#486)
- docker/setup-buildx-action v1 → v2 (osism/container-image-ceph-ansible#194)
- ghcr.io/astral-sh/uv 0.6.10 → 0.7.8 (osism/container-image-ceph-ansible#573) (osism/container-image-ceph-ansible#574) (osism/container-image-ceph-ansible#576) (osism/container-image-ceph-ansible#577) (osism/container-image-ceph-ansible#581) (osism/container-image-ceph-ansible#583) (osism/container-image-ceph-ansible#588) (osism/container-image-ceph-ansible#590) (osism/container-image-ceph-ansible#595) (osism/container-image-ceph-ansible#601) (osism/container-image-ceph-ansible#602) (osism/container-image-ceph-ansible#605) (osism/container-image-ceph-ansible#607) (osism/container-image-ceph-ansible#608)
- hiredis 2.0.0 → 2.2.2 (osism/container-image-ceph-ansible#238) (osism/container-image-ceph-ansible#258) (osism/container-image-ceph-ansible#265)
- idna 3.3 → 3.10 (osism/container-image-ceph-ansible#239) (osism/container-image-ceph-ansible#399) (osism/container-image-ceph-ansible#400) (osism/container-image-ceph-ansible#465) (osism/container-image-ceph-ansible#520) (osism/container-image-ceph-ansible#523) (osism/container-image-ceph-ansible#524)
- jinja2 3.0.1 → 3.1.6 (osism/container-image-ceph-ansible#163) (osism/container-image-ceph-ansible#184) (osism/container-image-ceph-ansible#424) (osism/container-image-ceph-ansible#479) (osism/container-image-ceph-ansible#547) (osism/container-image-ceph-ansible#563)
- mitogen 0.3.3 → 0.3.22 (osism/container-image-ceph-ansible#354) (osism/container-image-ceph-ansible#515) (osism/container-image-ceph-ansible#535) (osism/container-image-ceph-ansible#554) (osism/container-image-ceph-ansible#566)
- netaddr 0.8.0 → 1.3.0 (osism/container-image-ceph-ansible#371) (osism/container-image-ceph-ansible#415) (osism/container-image-ceph-ansible#416) (osism/container-image-ceph-ansible#430) (osism/container-image-ceph-ansible#489)
- osism 0.7.0 → 0.20230501.0 (osism/container-image-ceph-ansible#232) (osism/container-image-ceph-ansible#260) (osism/container-image-ceph-ansible#266) (osism/container-image-ceph-ansible#277) (osism/container-image-ceph-ansible#280) (osism/container-image-ceph-ansible#283) (osism/container-image-ceph-ansible#291) (osism/container-image-ceph-ansible#292) (osism/container-image-ceph-ansible#298) (osism/container-image-ceph-ansible#306) (osism/container-image-ceph-ansible#313)
- paramiko 2.9.2 → 3.5.1 (osism/container-image-ceph-ansible#181) (osism/container-image-ceph-ansible#240) (osism/container-image-ceph-ansible#256) (osism/container-image-ceph-ansible#329) (osism/container-image-ceph-ansible#357) (osism/container-image-ceph-ansible#414) (osism/container-image-ceph-ansible#510) (osism/container-image-ceph-ansible#525) (osism/container-image-ceph-ansible#555)
- pip 21.1.3 → 25.0.1 (osism/container-image-ceph-ansible#186) (osism/container-image-ceph-ansible#195) (osism/container-image-ceph-ansible#196) (osism/container-image-ceph-ansible#197) (osism/container-image-ceph-ansible#208) (osism/container-image-ceph-ansible#210) (osism/container-image-ceph-ansible#211) (osism/container-image-ceph-ansible#225) (osism/container-image-ceph-ansible#229) (osism/container-image-ceph-ansible#257) (osism/container-image-ceph-ansible#269) (osism/container-image-ceph-ansible#308) (osism/container-image-ceph-ansible#309) (osism/container-image-ceph-ansible#311) (osism/container-image-ceph-ansible#349) (osism/container-image-ceph-ansible#353) (osism/container-image-ceph-ansible#380) (osism/container-image-ceph-ansible#384) (osism/container-image-ceph-ansible#413) (osism/container-image-ceph-ansible#429) (osism/container-image-ceph-ansible#496) (osism/container-image-ceph-ansible#498) (osism/container-image-ceph-ansible#504) (osism/container-image-ceph-ansible#508) (osism/container-image-ceph-ansible#536) (osism/container-image-ceph-ansible#553) (osism/container-image-ceph-ansible#557)
- pottery 2.3.6 → 3.0.1 (osism/container-image-ceph-ansible#169) (osism/container-image-ceph-ansible#569)
- proxmoxer 1.2.0 → 1.3.0 (osism/container-image-ceph-ansible#176)
- pyclean 2.7.6 → 3.0.0 (osism/container-image-ceph-ansible#482)
- pymysql 1.0.2 → 1.1.1 (osism/container-image-ceph-ansible#302) (osism/container-image-ceph-ansible#345) (osism/container-image-ceph-ansible#484)
- pynetbox 6.6.1 → 7.0.1 (osism/container-image-ceph-ansible#235) (osism/container-image-ceph-ansible#248)
- python 3.11 → 3.13 (Docker base image) (osism/container-image-ceph-ansible#375) (osism/container-image-ceph-ansible#528)
- pyyaml 5.4.1 → 6.0.2 (osism/container-image-ceph-ansible#170) (osism/container-image-ceph-ansible#350) (osism/container-image-ceph-ansible#509)
- redis 4.1.4 → 4.5.5 (osism/container-image-ceph-ansible#189) (osism/container-image-ceph-ansible#241) (osism/container-image-ceph-ansible#249) (osism/container-image-ceph-ansible#263) (osism/container-image-ceph-ansible#264) (osism/container-image-ceph-ansible#299) (osism/container-image-ceph-ansible#300) (osism/container-image-ceph-ansible#303) (osism/container-image-ceph-ansible#322)
- requests 2.27.1 → 2.32.3 (osism/container-image-ceph-ansible#242) (osism/container-image-ceph-ansible#250) (osism/container-image-ceph-ansible#312) (osism/container-image-ceph-ansible#319) (osism/container-image-ceph-ansible#327) (osism/container-image-ceph-ansible#483) (osism/container-image-ceph-ansible#485) (osism/container-image-ceph-ansible#490)
- ruamel.yaml 0.17.21 → 0.18.4 (osism/container-image-ceph-ansible#318) (osism/container-image-ceph-ansible#321) (osism/container-image-ceph-ansible#323) (osism/container-image-ceph-ansible#328) (osism/container-image-ceph-ansible#330) (osism/container-image-ceph-ansible#331) (osism/container-image-ceph-ansible#333) (osism/container-image-ceph-ansible#340) (osism/container-image-ceph-ansible#373) (osism/container-image-ceph-ansible#376) (osism/container-image-ceph-ansible#377) (osism/container-image-ceph-ansible#381) (osism/container-image-ceph-ansible#382) (osism/container-image-ceph-ansible#383) (osism/container-image-ceph-ansible#385) (osism/container-image-ceph-ansible#387) (osism/container-image-ceph-ansible#390) (osism/container-image-ceph-ansible#392)
- setuptools 75.6.0 → 80.9.0 (osism/container-image-ceph-ansible#549) (osism/container-image-ceph-ansible#551) (osism/container-image-ceph-ansible#559) (osism/container-image-ceph-ansible#560) (osism/container-image-ceph-ansible#565) (osism/container-image-ceph-ansible#568) (osism/container-image-ceph-ansible#570) (osism/container-image-ceph-ansible#571) (osism/container-image-ceph-ansible#580) (osism/container-image-ceph-ansible#582) (osism/container-image-ceph-ansible#587) (osism/container-image-ceph-ansible#589) (osism/container-image-ceph-ansible#591) (osism/container-image-ceph-ansible#593) (osism/container-image-ceph-ansible#594) (osism/container-image-ceph-ansible#597) (osism/container-image-ceph-ansible#600) (osism/container-image-ceph-ansible#606)
- yq 2.12.2 → 3.4.3 (osism/container-image-ceph-ansible#168) (osism/container-image-ceph-ansible#204) (osism/container-image-ceph-ansible#209) (osism/container-image-ceph-ansible#272) (osism/container-image-ceph-ansible#304) (osism/container-image-ceph-ansible#310) (osism/container-image-ceph-ansible#367) (osism/container-image-ceph-ansible#466) (osism/container-image-ceph-ansible#467) (osism/container-image-ceph-ansible#468) (osism/container-image-ceph-ansible#472) (osism/container-image-ceph-ansible#473)

