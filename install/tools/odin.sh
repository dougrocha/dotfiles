#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTFILES_DIR/install/lib.sh"

ODIN_DIR="$BUILD_DIR/Odin"

mkdir -p "$BUILD_DIR" "$HOME/.local/bin"

sync_repo "$ODIN_DIR" https://github.com/odin-lang/Odin master
cd "$ODIN_DIR"

odin_commit=$(git rev-parse HEAD)

if needs_build odin "$odin_commit" "$ODIN_DIR/odin"; then
    make release-native
    mark_built odin "$odin_commit"
else
    info "odin already built at ${odin_commit:0:8}"
fi

ln -sf "$ODIN_DIR/odin" "$HOME/.local/bin/odin"

export PATH="$HOME/.local/bin:$PATH"
odin version

build_and_install() {
    local name="$1" repo="$2" branch="$3" build_cmd="$4"
    shift 4
    local bins=("$@")

    local dir="$BUILD_DIR/$name"

    sync_repo "$dir" "$repo" "$branch"
    cd "$dir"

    local commit
    commit="$(git rev-parse HEAD)-$odin_commit"

    local bin
    local outputs=("${bins[@]}")
    for bin in "${bins[@]}"; do
        outputs+=("$HOME/.local/bin/${bin##*/}")
    done

    if ! needs_build "$name" "$commit" "${outputs[@]}"; then
        info "$name already built"
        return
    fi

    for bin in "${bins[@]}"; do
        mkdir -p "$(dirname "$bin")"
    done

    bash -c "$build_cmd"
    cp "${bins[@]}" "$HOME/.local/bin/"
    mark_built "$name" "$commit"
}

build_stb() {
    local odin_root
    odin_root="$(odin root)"

    # Odin ships prebuilt STB for Windows/macOS/wasm only; the Linux .a files must
    # be compiled locally, and a pacman upgrade of `odin` wipes them every time.
    if [[ -f "$odin_root/vendor/stb/lib/stb_image.a" ]]; then
        return
    fi

    sudo "$odin_root/vendor/stb/src/build_stb.sh"
}

build_stb

build_and_install ols https://github.com/DanielGavin/ols.git master \
    "./build.sh && ./odinfmt.sh" ols odinfmt

build_and_install odin-tags https://github.com/GoNZooo/odin-tags.git main \
    "odin build tags -o:speed -out:bin/odin-tags" bin/odin-tags

# vim: ft=sh
