#!/bin/bash
# opencode v2 from the official installer, which installs to ~/.opencode/bin.

set -euo pipefail

OPENCODE_BIN="$HOME/.opencode/bin/opencode"
export PATH="$HOME/.opencode/bin:$PATH"

if [[ -x "$OPENCODE_BIN" ]]; then
    opencode upgrade
else
    curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
fi

opencode --version

# vim: ft=sh
