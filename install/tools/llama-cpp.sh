#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTFILES_DIR/install/lib.sh"

LLAMA_DIR="$BUILD_DIR/llama.cpp"

mkdir -p "$BUILD_DIR" "$HOME/.local/bin"

sync_repo "$LLAMA_DIR" https://github.com/ggml-org/llama.cpp master
cd "$LLAMA_DIR"

commit=$(git rev-parse HEAD)

cmake_args=(-DCMAKE_BUILD_TYPE=Release)
if [[ $PLATFORM_GPU == nvidia ]]; then
    cmake_args+=(-DGGML_CUDA=ON)
fi

if needs_build llama-cpp "$commit" "$LLAMA_DIR/build/bin/llama-server"; then
    cmake -B build "${cmake_args[@]}"
    cmake --build build -j
    mark_built llama-cpp "$commit"
else
    info "llama.cpp already built at ${commit:0:8}"
fi

ln -sf "$LLAMA_DIR/build/bin/llama-server" "$HOME/.local/bin/llama-server"

llama-server --version

# vim: ft=sh
