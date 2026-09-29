#!/usr/bin/env bash
# Tests for the cephadm guard wiring in files/scripts/run.sh.
#
# run.sh hardcodes container paths (/ansible, /opt/configuration, /src,
# /secrets.sh). The test rewrites them to a temporary root and runs the copy.
# Needs python3 with ansible-core importable, and ansible-playbook on PATH
# for the end-to-end cases.

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
ROOT=$WORK/root

failures=0
ok() { echo "ok   $1"; }
fail() { echo "FAIL $1"; failures=$((failures + 1)); }

# Build a fake container root. $1 = guard playbook to install ("real" or "stub").
make_root() {
    rm -rf "$ROOT"
    mkdir -p "$ROOT/ansible/inventory" "$ROOT/src" "$ROOT/opt/configuration/environments/ceph" "$ROOT/bin"
    local env=$ROOT/opt/configuration/environments
    echo "dummy" > "$env/.vault_pass"
    for f in "$env/configuration.yml" "$env/secrets.yml" "$env/ceph/secrets.yml" "$env/ceph/images.yml" "$env/ceph/configuration.yml"; do
        echo "dummy_var: 1" > "$f"
    done
    : > "$ROOT/secrets.sh"
    cp "$REPO/files/src/cephadm-guard-mode.py" "$ROOT/src/"
    if [[ $1 == real ]]; then
        cp "$REPO/files/playbooks/cephadm-guard.yml" "$ROOT/ansible/"
    else
        echo "---" > "$ROOT/ansible/cephadm-guard.yml"
    fi
    printf -- '---\n- name: Service\n  hosts: all\n  gather_facts: false\n  tasks:\n    - name: Service ran\n      ansible.builtin.debug:\n        msg: SERVICE-RAN\n' > "$ROOT/ansible/ceph-mons.yml"
    sed -e "s#/ansible#$ROOT/ansible#g" \
        -e "s#/opt/configuration#$ROOT/opt/configuration#g" \
        -e "s#/src/#$ROOT/src/#g" \
        -e "s#/secrets.sh#$ROOT/secrets.sh#g" \
        "$REPO/files/scripts/run.sh" > "$ROOT/run.sh"
    chmod +x "$ROOT/run.sh"
}

# A stub ansible-playbook that logs each call's argv, one %q-quoted
# argument per line, calls separated by "--", and fails the guard call
# when STUB_GUARD_RC is set.
install_stub() {
    cat > "$ROOT/bin/ansible-playbook" <<'STUB'
#!/usr/bin/env bash
for a in "$@"; do printf '%q\n' "$a"; done >> "$STUB_LOG"
echo "--" >> "$STUB_LOG"
if [[ ${!#} == */cephadm-guard.yml ]]; then exit "${STUB_GUARD_RC:-0}"; fi
exit 0
STUB
    chmod +x "$ROOT/bin/ansible-playbook"
}

# Print call N (1-based) from the stub log.
call() { awk -v n="$1" 'BEGIN{c=1} /^--$/{c++; next} c==n' "$STUB_LOG"; }
calls() { grep -c '^--$' "$STUB_LOG"; }

# ---- stub cases ----------------------------------------------------------

make_root stub
install_stub
export STUB_LOG=$WORK/stub.log

: > "$STUB_LOG"
if STUB_GUARD_RC=2 PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons > "$WORK/out" 2>&1; then
    fail "15a guard failure stops run.sh (exit 0)"
elif [[ $(calls) -ne 1 ]]; then
    fail "15a guard failure stops run.sh ($(calls) calls)"
else
    ok "15a guard failure: service never invoked"
fi

: > "$STUB_LOG"
if PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons --step > "$WORK/out" 2>&1; then
    fail "15b helper refusal stops run.sh (exit 0)"
elif [[ $(calls) -ne 0 ]] || ! grep -q -- "--step" "$WORK/out"; then
    fail "15b helper refusal: $(calls) calls, output: $(cat "$WORK/out")"
else
    ok "15b helper refusal: nothing invoked"
fi

: > "$STUB_LOG"
PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons --list-tasks > "$WORK/out" 2>&1
if [[ $(calls) -eq 1 ]] && call 1 | grep -q "ceph-mons.yml$"; then
    ok "13 --list-tasks: guard skipped, service invoked"
else
    fail "13 --list-tasks: $(calls) calls"
fi

user_args=(-e '{"x": "a b"}' -i '/tmp/inv dir/hosts' --ssh-common-args '-o A=b -o C=d' -l node-3 --lim node-4 -vl node-5 --limit=node-6 -t foo)
expected_user=$(for a in "${user_args[@]}"; do printf '%q\n' "$a"; done)
expected_appended=$(printf '%q\n' --limit all,localhost --start-at-task 'Check that the Ceph mon group is not empty')

check_args() {
    local label=$1 guard service
    guard=$(call 1)
    service=$(call 2)
    if [[ $(calls) -ne 2 ]]; then
        fail "$label: expected 2 calls, got $(calls)"
        return
    fi
    # Both calls end with the user's args (before the playbook for the
    # service; before the two appended options and the playbook for the guard).
    local guard_tail service_tail
    guard_tail=$(echo "$guard" | tail -n $((${#user_args[@]} + 5)) | head -n ${#user_args[@]})
    service_tail=$(echo "$service" | tail -n $((${#user_args[@]} + 1)) | head -n ${#user_args[@]})
    local appended
    appended=$(echo "$guard" | tail -n 5 | head -n 4)
    if [[ $guard_tail != "$expected_user" ]]; then
        fail "$label: guard args differ"; diff <(echo "$expected_user") <(echo "$guard_tail") | sed 's/^/     | /'
    elif [[ $service_tail != "$expected_user" ]]; then
        fail "$label: service args differ"; diff <(echo "$expected_user") <(echo "$service_tail") | sed 's/^/     | /'
    elif [[ $appended != "$expected_appended" ]]; then
        fail "$label: guard call does not end with the overrides"; echo "$appended" | sed 's/^/     | /'
    else
        ok "$label"
    fi
}

: > "$STUB_LOG"
PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons "${user_args[@]}" > "$WORK/out" 2>&1
check_args "16 arguments reach both calls unchanged"

: > "$STUB_LOG"
quoted=$(python3 -c 'import shlex, sys; print(" ".join(shlex.quote(a) for a in sys.argv[1:]))' "${user_args[@]}")
PATH="$ROOT/bin:$PATH" sh -c "$ROOT/run.sh mons $quoted" > "$WORK/out" 2>&1
check_args "17 python-osism style sh -c invocation"

: > "$STUB_LOG"
PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons,mgrs > "$WORK/out" 2>&1
if [[ $(calls) -eq 2 ]] && call 1 | grep -q "cephadm-guard.yml$" && call 2 | grep -q "ceph-mons.yml$"; then
    ok "multi-service: guard runs once, first"
else
    fail "multi-service: $(calls) calls"
fi
# ceph-mgrs.yml does not exist in the fake root, so run.sh stops after
# ceph-mons; the point is that the guard ran exactly once, before it.

: > "$STUB_LOG"
echo "---" > "$ROOT/opt/configuration/environments/ceph/playbook-mons.yml"
PATH="$ROOT/bin:$PATH" "$ROOT/run.sh" mons > "$WORK/out" 2>&1
if [[ $(calls) -eq 2 ]] && call 1 | grep -q "cephadm-guard.yml$" && call 2 | grep -q "^playbook-mons.yml$"; then
    ok "environment playbook override is guarded too"
else
    fail "environment playbook override: $(calls) calls"
fi
rm "$ROOT/opt/configuration/environments/ceph/playbook-mons.yml"

# ---- end-to-end cases, real ansible-playbook -----------------------------

make_root real
data=$WORK/data
mkdir -p "$data/cephadm/fsid/mon.node-0" "$data/legacy/mon/ceph-node-0"
host="ansible_connection=local ansible_become=false ansible_python_interpreter=auto_silent"
# The default inventory's mon is legacy; migrated.ini's mon is cephadm.
printf '[ceph-mon]\nnode-0 %s ceph_cephadm_guard_data_dir=%s\n[ceph-osd]\nnode-3 %s\n' "$host" "$data/legacy" "$host" > "$ROOT/ansible/inventory/hosts.yml"
chmod 444 "$ROOT/ansible/inventory/hosts.yml"
printf '[ceph-mon]\nnode-0 %s ceph_cephadm_guard_data_dir=%s\n' "$host" "$data/cephadm" > "$WORK/migrated.ini"

e2e() {
    local want=$1 label=$2
    shift 2
    local out rc
    out=$("$ROOT/run.sh" mons "$@" < /dev/null 2>&1)
    rc=$?
    if [[ $want == refuse ]] && [[ $rc -ne 0 ]] && ! grep -q SERVICE-RAN <<< "$out" && grep -q "managed by cephadm" <<< "$out"; then
        ok "$label"
    elif [[ $want == pass ]] && [[ $rc -eq 0 ]] && grep -q SERVICE-RAN <<< "$out"; then
        ok "$label"
    else
        fail "$label (exit $rc)"; echo "$out" | tail -15 | sed 's/^/     | /'
    fi
}

cephadm_dir=(-e "ceph_cephadm_guard_data_dir=$data/cephadm")
e2e refuse "18a -l non-mon host" "${cephadm_dir[@]}" -l node-3
e2e refuse "18b --lim non-mon host" "${cephadm_dir[@]}" --lim node-3
e2e refuse "18c -vl non-mon host" "${cephadm_dir[@]}" -vl node-3
e2e refuse "18d --limit= non-mon host" "${cephadm_dir[@]}" --limit=node-3
e2e refuse "19a --tags foo" "${cephadm_dir[@]}" --tags foo
e2e refuse "19b --start-at-task nomatch" "${cephadm_dir[@]}" --start-at-task nomatch
e2e pass "legacy cluster runs the service"
e2e refuse "20 -i selects a migrated cluster" -i "$WORK/migrated.ini"
e2e pass "21 opt-out" "${cephadm_dir[@]}" -l node-3 -e ceph_cephadm_guard=false

# mon_group_name set in the environment configuration reaches the guard.
chmod 644 "$ROOT/ansible/inventory/hosts.yml"
printf '[mons]\nnode-0 %s ceph_cephadm_guard_data_dir=%s\n[ceph-mon]\nnode-9 %s ceph_cephadm_guard_data_dir=%s\n' "$host" "$data/cephadm" "$host" "$data/legacy" > "$ROOT/ansible/inventory/hosts.yml"
chmod 444 "$ROOT/ansible/inventory/hosts.yml"
echo "mon_group_name: mons" >> "$ROOT/opt/configuration/environments/ceph/configuration.yml"
e2e refuse "mon_group_name from configuration.yml"

if [[ $failures -gt 0 ]]; then
    echo "$failures failure(s)"
    exit 1
fi
echo "all passed"
