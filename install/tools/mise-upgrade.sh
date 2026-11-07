#!/bin/bash
# With lockfile = true, `mise install` in mise.sh stays on the versions in mise.lock, even for "latest" and "lts".
# Only `mise upgrade` moves them forward and rewrites the lock.

set -euo pipefail

mise upgrade --yes

# vim: ft=sh
