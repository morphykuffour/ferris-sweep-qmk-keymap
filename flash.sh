#!/usr/bin/env bash
#
# Flash Ferris Sweep firmware to keyboard
#

set -euo pipefail

FIRMWARE="${1:-/Users/morph/git/vial-qmk/ferris_sweep_colemak-dh_rp2040_ce.uf2}"
MOUNT_POINT="/Volumes/RPI-RP2"
TIMEOUT=60

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

if [ ! -f "$FIRMWARE" ]; then
    error "Firmware not found: $FIRMWARE"
    error "Run ./build.sh first"
    exit 1
fi

info "Firmware: $FIRMWARE"
info "Waiting for keyboard bootloader (${MOUNT_POINT})..."
info "Double-tap reset button on your keyboard now!"

elapsed=0
while [ ! -d "$MOUNT_POINT" ]; do
    sleep 1
    elapsed=$((elapsed + 1))
    if [ $elapsed -ge $TIMEOUT ]; then
        error "Timeout waiting for bootloader"
        exit 1
    fi
    printf "."
done
echo ""

info "Bootloader detected! Flashing..."
cp "$FIRMWARE" "$MOUNT_POINT/"

# Wait for drive to unmount (indicates flash complete)
sleep 2
if [ ! -d "$MOUNT_POINT" ]; then
    success "Firmware flashed successfully!"
else
    warn "Drive still mounted - flash may have failed"
fi

echo ""
info "If you have a split keyboard, repeat for the other half."
