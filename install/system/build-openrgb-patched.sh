#!/bin/bash

set -euo pipefail

PATCH_FILE="$DOTFILES_DIR/default/patches/openrgb-lianli-unihub-sl-fix.patch"
SRC_DIR="$BUILD_DIR/openrgb-src"

echo "Patched OpenRGB Build (Lian Li Uni Hub SL color fix)"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo "Fixes GitLab issue #5768: stock OpenRGB's Lian Li Uni Hub SL driver"
echo "truncates every color write to 8 bytes (sizeof(pointer) bug) and never"
echo "sends anything in Custom mode (bad active_mode==0 guard). Both bugs"
echo "combine to make color control a permanent no-op on this device."
echo ""

for tool in git qmake6 make; do
    if ! command -v "$tool" &> /dev/null; then
        echo "✗ Error: $tool not found."
        exit 1
    fi
done

if [[ ! -f "$PATCH_FILE" ]]; then
    echo "✗ Error: patch file not found at $PATCH_FILE"
    exit 1
fi

if [[ -d "$SRC_DIR" ]]; then
    echo "✗ Error: $SRC_DIR already exists. Remove it first if you want a clean rebuild."
    exit 1
fi

echo "Cloning OpenRGB into $SRC_DIR..."
git clone --depth 1 https://gitlab.com/CalcProgrammer1/OpenRGB.git "$SRC_DIR"

echo ""
echo "Applying patch..."

if (cd "$SRC_DIR" && git apply --reverse --check "$PATCH_FILE" 2>/dev/null); then
    echo "✗ This fix is already present upstream — the patch no longer applies"
    echo "  because it's already applied (verified via reverse-apply check)."
    echo ""
    echo "  Upstream has merged this fix. You should:"
    echo "    1. Delete $PATCH_FILE"
    echo "    2. Remove the 'Applying patch' step from this script"
    echo "    3. Rebuild without patching — vanilla OpenRGB now has the fix"
    echo ""
    echo "  Aborting so nothing gets silently skipped."
    rm -rf "$SRC_DIR"
    exit 1
fi

(cd "$SRC_DIR" && git apply "$PATCH_FILE")

echo ""
echo "Configuring..."
(cd "$SRC_DIR" && qmake6 OpenRGB.pro)

echo ""
echo "Building (this takes a few minutes)..."
(cd "$SRC_DIR" && make -j"$(nproc)")

echo ""
echo "✓ Patched OpenRGB built successfully!"
echo ""
echo "Binary: $SRC_DIR/openrgb"
echo "Run:    $SRC_DIR/openrgb --profile MutedBlue"
echo ""
echo "This is what openrgb-profile.service (systemctl --user) points at."

# vim: ft=sh
