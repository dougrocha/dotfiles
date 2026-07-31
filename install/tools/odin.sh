#!/bin/bash

set -euo pipefail

build_and_install() {
    local name="$1"
    local repo="$2"
    local branch="$3"
    local build_cmd="$4"
    shift 4
    local bins=("$@")

    local dir="$BUILD_DIR/$name"

    mkdir -p "$BUILD_DIR"

    if [[ -d "$dir" ]]; then
        cd "$dir"
        git pull origin "$branch"
    else
        git clone "$repo" "$dir"
        cd "$dir"
    fi

    bash -c "$build_cmd"
    cp "${bins[@]}" "$HOME/.local/bin/"
}

build_and_install ols https://github.com/DanielGavin/ols.git master \
    "./build.sh && ./odinfmt.sh" ols odinfmt

build_and_install odin-tags https://github.com/GoNZooo/odin-tags.git main \
    "odin build tags -o:speed -out:bin/odin-tags" bin/odin-tags
