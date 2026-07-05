#!/bin/bash

set -euo pipefail

OLS_DIR="$BUILD_DIR/ols"

mkdir -p "$BUILD_DIR"

if [[ -d "$OLS_DIR" ]]; then
    cd "$OLS_DIR"
    git pull origin master
else
    git clone https://github.com/DanielGavin/ols.git "$OLS_DIR"
    cd "$OLS_DIR"
fi

./build.sh
./odinfmt.sh
cp ols odinfmt "$HOME/.local/bin/"
