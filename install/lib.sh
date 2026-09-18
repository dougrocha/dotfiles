#!/bin/bash
# Helpers and platform detection. Sourced by setup and the step scripts.

set -euo pipefail

: "${DOTFILES_DIR:?lib.sh needs DOTFILES_DIR}"
export BUILD_DIR="${BUILD_DIR:-$HOME/builds}"

case "$(uname -s)" in
    Darwin) PLATFORM_OS=darwin ;;
    Linux) PLATFORM_OS=linux ;;
    *)
        echo "dotfiles: unsupported system $(uname -s)" >&2
        exit 1
        ;;
esac

PLATFORM_ARCH="$(uname -m)"
PLATFORM_GPU=none
if command -v lspci >/dev/null 2>&1 && lspci | grep -qi nvidia; then
    PLATFORM_GPU=nvidia
fi

export PLATFORM_OS PLATFORM_ARCH PLATFORM_GPU

# Steps use tools an earlier step installed, before any login shell sets PATH.
for dir in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.opencode/bin"; do
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) PATH="$dir:$PATH" ;;
    esac
done
export PATH

is_linux() { [[ $PLATFORM_OS == linux ]]; }
is_darwin() { [[ $PLATFORM_OS == darwin ]]; }
has() { command -v "$1" >/dev/null 2>&1; }

step() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*" >&2; }

# Hold the sudo timestamp open so later steps never prompt.
keep_sudo_alive() {
    sudo -v || return 1
    while true; do
        sudo -n true 2>/dev/null || return 0
        sleep 50
    done &
    local pid=$!
    # shellcheck disable=SC2064  # pid must expand now, not when the trap fires
    trap "kill $pid 2>/dev/null || true" EXIT
}

# Force the checkout to origin/<branch>. git pull fails on a dirty build tree.
sync_repo() {
    local dir="$1" url="$2" branch="$3"

    if [[ -d "$dir/.git" ]]; then
        git -C "$dir" fetch --prune origin "$branch"
        git -C "$dir" checkout -B "$branch" "origin/$branch"
        git -C "$dir" reset --hard "origin/$branch"
    else
        # Blobless: small, but keeps the history that git describe needs.
        git clone --filter=blob:none --branch "$branch" "$url" "$dir"
    fi
}

needs_build() {
    local name=$1 commit=$2
    shift 2
    local stamp="$BUILD_DIR/.stamp-$name"
    local bin

    if [[ ${FORCE:-0} == 1 ]]; then return 0; fi
    if [[ ! -f $stamp ]]; then return 0; fi
    if [[ $(cat "$stamp") != "$commit" ]]; then return 0; fi
    for bin in "$@"; do
        if [[ ! -x $bin ]]; then return 0; fi
    done
    return 1
}

mark_built() {
    printf '%s\n' "$2" >"$BUILD_DIR/.stamp-$1"
}

# One name per line, # starts a comment.
read_package_list() {
    grep -v '^[[:space:]]*#' "$1" | sed 's/[[:space:]]*#.*$//' | awk 'NF'
}

# vim: ft=sh
