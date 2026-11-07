#!/bin/bash
# The Homebrew build of mise disables self-update, so install with the official script.

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

if mise --version >/dev/null 2>&1; then
    mise self-update --yes
else
    curl -fsSL https://mise.run | sh
fi

mise --version

mise install

# vim: ft=sh
