#!/bin/bash
# mise, via the official installer. The Homebrew build disables mise self-update.

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

if mise --version >/dev/null 2>&1; then
    mise self-update --yes
else
    curl -fsSL https://mise.run | sh
fi

mise --version

# vim: ft=sh
