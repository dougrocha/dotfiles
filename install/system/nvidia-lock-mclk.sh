#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

SERVICE_FILE="$DOTFILES_DIR/default/systemd/nvidia/nvidia-lock-mclk.service"

echo "NVIDIA Memory Clock Locking Setup"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

# Check if nvidia-smi is available
if ! command -v nvidia-smi &> /dev/null; then
    echo "✗ Error: nvidia-smi not found. Please install NVIDIA drivers first."
    exit 1
fi

echo "Querying available memory clocks..."
CLOCKS_OUTPUT=$(nvidia-smi --query-supported-clocks=memory --format=csv,noheader 2>/dev/null || echo "")

if [[ -z "$CLOCKS_OUTPUT" ]]; then
    echo "✗ Error: Could not query supported memory clocks."
    echo "  Try running manually: nvidia-smi --query-supported-clocks=memory --format=csv"
    exit 1
fi

readarray -t CLOCKS < <(echo "$CLOCKS_OUTPUT" | tr ',' '\n' | sort -n)

echo ""
echo "Available memory clocks (MHz):"
echo "───────────────────────────────────────────────────────────────────────────"
for clock in "${CLOCKS[@]}"; do
    echo "  • $clock MHz"
done
echo ""

MODE=$(gum choose "Single clock (max only)" "Range (min and max)" --header="Select configuration mode")

if [[ -z "$MODE" ]]; then
    echo "✗ Cancelled"
    exit 1
fi

echo ""

if [[ "$MODE" == "Single clock (max only)" ]]; then
    MAX_CLOCK=$(gum choose "${CLOCKS[@]}" --header="Select memory clock to lock at" --height=10)

    if [[ -z "$MAX_CLOCK" ]]; then
        echo "✗ Cancelled"
        exit 1
    fi
    MIN_CLOCK="$MAX_CLOCK"
    CLOCK_CONFIG="$MAX_CLOCK MHz (locked to single value)"

else
    MIN_CLOCK=$(gum choose "${CLOCKS[@]}" --header="Select MINIMUM memory clock" --height=10)

    if [[ -z "$MIN_CLOCK" ]]; then
        echo "✗ Cancelled"
        exit 1
    fi

    MAX_CLOCK=$(gum choose "${CLOCKS[@]}" --header="Select MAXIMUM memory clock" --height=10)

    if [[ -z "$MAX_CLOCK" ]]; then
        echo "✗ Cancelled"
        exit 1
    fi

    CLOCK_CONFIG="$MIN_CLOCK-$MAX_CLOCK MHz (range)"
fi

echo ""
echo "Configuration Summary:"
echo "───────────────────────────────────────────────────────────────────────────"
echo "  Clock Setting: $CLOCK_CONFIG"
echo ""

if ! gum confirm "Deploy NVIDIA memory clock locking service with these settings?"; then
    echo "✗ Cancelled"
    exit 1
fi

echo ""
echo "Deploying service..."

if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "✗ Error: Service file not found at $SERVICE_FILE"
    exit 1
fi

MIN_CLOCK_NUM="${MIN_CLOCK%% MHz}"
MAX_CLOCK_NUM="${MAX_CLOCK%% MHz}"

TEMP_SERVICE=$(mktemp)
sed "s/<MIN_FREQ>/$MIN_CLOCK_NUM/g; s/<MAX_FREQ>/$MAX_CLOCK_NUM/g" "$SERVICE_FILE" > "$TEMP_SERVICE"

sudo cp "$TEMP_SERVICE" /etc/systemd/system/nvidia-lock-mclk.service
rm "$TEMP_SERVICE"

sudo systemctl daemon-reload
sudo systemctl enable --now nvidia-lock-mclk.service

echo "✓ NVIDIA memory clock locking service deployed successfully!"
echo ""
echo "Service Details:"
echo "───────────────────────────────────────────────────────────────────────────"
echo "  Clock Configuration: $CLOCK_CONFIG"
echo "  Actual setting:      $MIN_CLOCK_NUM,$MAX_CLOCK_NUM MHz"
echo "  Status:   systemctl status nvidia-lock-mclk"
echo "  Logs:     journalctl -u nvidia-lock-mclk"
echo "  Disable:  sudo systemctl disable --now nvidia-lock-mclk"
