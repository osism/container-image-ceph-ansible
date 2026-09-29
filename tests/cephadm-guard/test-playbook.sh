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

cephadm=$WORK/cephadm; mkdir -p "$cephadm/0c5e6d8e-fsid/mon.node-0"
legacy=$WORK/legacy; mkdir -p "$legacy/mon/ceph-node-0"
empty=$WORK/empty; mkdir -p "$empty"
missing=$WORK/missing
locked=$WORK/locked; mkdir -p "$locked/mon/ceph-node-0" "$locked/sub"; chmod 000 "$locked/sub"
file=$WORK/file; touch "$file"

one=$(inventory one node-0:local)
two=$(inventory two node-0:local node-1:unreachable)
down=$(inventory down node-1:unreachable node-2:unreachable)
none=$(inventory none)
broken=$(inventory broken node-0:local node-1:broken)

expect refuse "1 cephadm layout" "managed by cephadm.*node-0: found .*mon\.node-0" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm"
expect pass "2 legacy layout" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$legacy"
expect pass "3a empty data dir" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$empty"
expect pass "3b missing data dir" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$missing"
expect pass "4 opt-out" "" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm" -e ceph_cephadm_guard=false
expect refuse "5 cephadm plus unreachable" "managed by cephadm" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$cephadm"
expect refuse "6 legacy plus unreachable" "Could not determine.*node-1: unreachable" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "7 all unreachable" "Could not determine.*node-1: unreachable.*node-2: unreachable" -- -i "$down" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "8 unreachable adopted mon" "Could not determine.*node-1: unreachable" -- -i "$two" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "9a empty mon group" "group ceph-mon has no hosts" -- -i "$none" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "9b unknown mon group name" "group mons has no hosts" -- -i "$one" -e mon_group_name=mons -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "10 unreadable subdirectory" "Could not determine.*node-0: could not read .*locked" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$locked"
expect refuse "11 data dir is a file" "Could not determine.*node-0: .*file is not a directory" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$file"
expect refuse "12 task failure on a mon host" "fatal: \[node-1\]: FAILED" -- -i "$broken" -e "ceph_cephadm_guard_data_dir=$legacy"
expect refuse "--check still refuses" "managed by cephadm" -- -i "$one" -e "ceph_cephadm_guard_data_dir=$cephadm" --check

if [[ $failures -gt 0 ]]; then
    echo "$failures failure(s)"
    exit 1
fi
echo "all passed"
