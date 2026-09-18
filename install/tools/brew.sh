#!/bin/bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
    for prefix in /opt/homebrew /usr/local; do
        if [[ -x "$prefix/bin/brew" ]]; then
            export PATH="$prefix/bin:$PATH"
            break
        fi
    done
fi

if command -v brew >/dev/null 2>&1; then
    brew update
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# A fresh install is not on PATH, and the prefix differs by architecture.
for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
        eval "$("$prefix/bin/brew" shellenv bash)"
        break
    fi
done

brew --version

# vim: ft=sh
