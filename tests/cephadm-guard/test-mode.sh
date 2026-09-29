#!/usr/bin/env bash
# Tests for files/src/cephadm-guard-mode.py against ansible-playbook's real
# argument parser. Needs python3 with ansible-core importable.

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
HELPER=$HERE/../../files/src/cephadm-guard-mode.py

failures=0

# expect run|skip|refuse ARGS...
expect() {
    local want=$1 out rc
    shift
    out=$(python3 "$HELPER" "$@" 2> /dev/null < /dev/null)
    rc=$?
    if { [[ $want == refuse ]] && [[ $rc -ne 0 ]] && [[ -z $out ]]; } ||
        { [[ $want != refuse ]] && [[ $rc -eq 0 ]] && [[ $out == "$want" ]]; }; then
        echo "ok   $want: $*"
    else
        echo "FAIL $want: $* (stdout '$out', exit $rc)"
        failures=$((failures + 1))
    fi
}

expect run
expect run -l node-3
expect run --lim node-3
expect run -vl node-3
expect run --limit=node-3
expect run -t foo
expect run --start-at-task x
expect run -C
expect run --skip-tags all
expect run -e '{"x": "a b"}' -i '/tmp/inv dir/hosts'

expect skip --list-tasks
expect skip --list-tas
expect skip --list-hosts
expect skip --list-tags
expect skip --syntax-check
expect skip --version
expect skip -h

expect refuse --skip-tags always
expect refuse --skip-t always
expect refuse --skip-tags foo,always
expect refuse --skip-tags=always
expect refuse --step
expect refuse --ste
expect refuse --st
expect refuse --no-such-option

if [[ $failures -gt 0 ]]; then
    echo "$failures failure(s)"
    exit 1
fi
echo "all passed"
