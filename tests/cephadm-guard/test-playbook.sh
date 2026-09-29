#!/usr/bin/env bash
# Scenario tests for files/playbooks/cephadm-guard.yml against localhost.
# Usage: tests/cephadm-guard/test-playbook.sh [path/to/cephadm-guard.yml]
# Needs ansible-playbook on PATH, or ANSIBLE_PLAYBOOK set to a command.

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
PLAYBOOK=${1:-$HERE/../../files/playbooks/cephadm-guard.yml}
ANSIBLE_PLAYBOOK=${ANSIBLE_PLAYBOOK:-ansible-playbook}
WORK=$(mktemp -d)
trap 'chmod -R u+rwx "$WORK"; rm -rf "$WORK"' EXIT

failures=0

# inventory NAME HOST... ; each HOST is "name:local", "name:broken" (module
# execution fails) or "name:unreachable"
inventory() {
    local file=$WORK/$1.ini
    shift
    echo "[ceph-mon]" > "$file"
    for host in "$@"; do
        case ${host#*:} in
            local) echo "${host%%:*} ansible_connection=local ansible_become=false ansible_python_interpreter=auto_silent" >> "$file" ;;
            broken) echo "${host%%:*} ansible_connection=local ansible_become=false ansible_python_interpreter=/nonexistent/python" >> "$file" ;;
            unreachable) echo "${host%%:*} ansible_host=192.0.2.1 ansible_ssh_common_args='-o ConnectTimeout=2'" >> "$file" ;;
        esac
    done
    echo "$file"
}

# expect pass|refuse DESCRIPTION PATTERN -- ANSIBLE_ARGS...
expect() {
    local want=$1 description=$2 pattern=$3
    shift 4
    local out rc
    out=$($ANSIBLE_PLAYBOOK "$@" "$PLAYBOOK" < /dev/null 2>&1)
    rc=$?
    if [[ $want == pass && $rc -eq 0 ]] || [[ $want == refuse && $rc -ne 0 ]]; then
        if [[ -z $pattern ]] || grep -qE -- "$pattern" <<< "$out"; then
            echo "ok   $description"
            return
        fi
        echo "FAIL $description: output lacks /$pattern/"
    else
        echo "FAIL $description: expected $want, exit code $rc"
    fi
    echo "$out" | sed 's/^/     | /' | tail -20
    failures=$((failures + 1))
}

fsid=ef9dd62c-ca3d-4b22-a10b-d62197511f63
cephadm=$WORK/cephadm; mkdir -p "$cephadm/$fsid/mon.node-0"
legacy=$WORK/legacy; mkdir -p "$legacy/mon/ceph-node-0" "$legacy/osd/ceph-0" "$legacy/bootstrap-osd" "$legacy/tmp" "$legacy/crash"
# cephadm moved the mons elsewhere; only the fsid dir with removed/ and crash/ is left.
moved=$WORK/moved; mkdir -p "$moved/$fsid/removed/mon.node-0_2026-09-29T10:00:00Z" "$moved/$fsid/crash"
ln -s "$legacy" "$WORK/legacy-link"; ln -s "$cephadm" "$WORK/cephadm-link"
empty=$WORK/empty; mkdir -p "$empty"
missing=$WORK/missing
locked=$WORK/locked; mkdir -p "$locked/mon/ceph-node-0"; chmod 000 "$locked"
file=$WORK/file; touch "$file"

one=$(inventory one node-0:local)
two=$(inventory two node-0:local node-1:unreachable)
down=$(inventory down node-1:unreachable node-2:unreachable)
none=$(inventory none)
broken=$(inventory broken node-0:local node-1:broken)
pair=$(inventory pair node-0:local node-1:local)

expect refuse "1 cephadm layout" "This Ceph cluster is managed by cephadm.*node-0: found .*$fsid" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm"
expect pass "2 legacy layout" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$legacy"
expect pass "3a empty data dir" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$empty"
expect pass "3b missing data dir" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$missing"
expect pass "4 opt-out" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm" -e ceph_cephadm_guard=false
expect refuse "5 cephadm plus unreachable" "This Ceph cluster is managed by cephadm" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$cephadm"
expect refuse "6 legacy plus unreachable" "Could not determine.*node-1: unreachable" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "7 all unreachable" "Could not determine.*node-1: unreachable.*node-2: unreachable" -- -i "$down" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "8 unreachable adopted mon" "Could not determine.*node-1: unreachable" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "9a empty mon group" "group ceph-mon has no hosts" -- -i "$none" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "9b unknown mon group name" "group mons has no hosts" -- -i "$one" -e mon_group_name=mons -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "10 unreadable data dir" "Could not determine.*node-0: could not read .*locked" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$locked"
expect refuse "11 data dir is a file" "Could not determine.*node-0: .*file is not a directory" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$file"
expect refuse "12 task failure on a mon host" "fatal: \[node-1\]: FAILED" -- -i "$broken" -e "ceph_cephadm_guard_data_dir=$legacy"
expect pass "13a data dir symlinked to a legacy layout" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$WORK/legacy-link"
expect refuse "13b data dir symlinked to a cephadm layout" "This Ceph cluster is managed by cephadm" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$WORK/cephadm-link"
ANSIBLE_STRATEGY=free expect pass "14 free strategy, legacy mons" "" -- -i "$pair" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "15 extra vars named like guard internals" "This Ceph cluster is managed by cephadm" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm" \
    -e '{"_cephadm": [], "_inconclusive": [], "_results": [], "_state": "clean", "_found": [], "_skipped": [], "_unreachable": false, "_detail": "", "_data_dir": "/nonexistent", "_mon_group": "ceph-mon"}'
expect refuse "16 mons moved off the inventory hosts" "This Ceph cluster is managed by cephadm.*found .*$fsid" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$moved"
expect refuse "--check still refuses" "This Ceph cluster is managed by cephadm" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm" --check

if [[ $failures -gt 0 ]]; then
    echo "$failures failure(s)"
    exit 1
fi
echo "all passed"
