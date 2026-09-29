# SPDX-License-Identifier: Apache-2.0

# Decide how run.sh runs the cephadm guard (cephadm-guard.yml) for the given
# ansible-playbook arguments. The arguments are parsed with ansible-playbook's
# own parser, so abbreviations (--skip-t) and combined short options (-vl)
# are resolved exactly as the real run resolves them.
#
# Prints "run" or "skip" on stdout. Exits non-zero, with the reason on
# stderr, when the arguments would let the guard be skipped.

import contextlib
import sys

from ansible.cli.playbook import PlaybookCLI


def main(argv):
    cli = PlaybookCLI(["ansible-playbook", *argv, "cephadm-guard.yml"])
    cli.init_parser()
    # argparse writes --help/--version output to stdout, which run.sh
    # captures; send it to stderr so stdout only ever holds the mode.
    with contextlib.redirect_stdout(sys.stderr):
        try:
            options = cli.parser.parse_args(cli.args[1:])
        except SystemExit as e:
            if e.code == 0:
                print("skip", file=sys.__stdout__)
                return 0
            print(
                "ERROR: the cephadm guard could not parse these arguments",
                file=sys.stderr,
            )
            return 1

    if options.listhosts or options.listtasks or options.listtags or options.syntax:
        print("skip")
        return 0

    skip_tags = {
        tag.strip() for value in options.skip_tags or [] for tag in value.split(",")
    }
    if "always" in skip_tags:
        print(
            "ERROR: --skip-tags always would skip the cephadm guard; drop it",
            file=sys.stderr,
        )
        return 1
    if options.step:
        print(
            "ERROR: --step cannot be used with the cephadm guard; drop it",
            file=sys.stderr,
        )
        return 1

    print("run")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
