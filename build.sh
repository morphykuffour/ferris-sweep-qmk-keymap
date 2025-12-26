#!/usr/bin/env bash
#
# Ferris Sweep QMK Firmware Build Script
#

set -euo pipefail

# Configuration
VIAL_QMK_DIR="${VIAL_QMK_DIR:-$HOME/git/vial-qmk}"
KEYBOARD="ferris/sweep"
KEYMAP_NAME="${KEYMAP_NAME:-colemak-dh}"
CONVERT_TO="${CONVERT_TO:-rp2040_ce}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Build firmware for Ferris Sweep keyboard"
    echo
    echo "Options:"
    echo "  -c, --clean         Clean build before compiling"
    echo "  -f, --flash         Flash firmware after building"
    echo "  -l, --left          Flash left half only"
    echo "  -r, --right         Flash right half only"
    echo "  --convert-to TYPE   Set converter (default: rp2040_ce)"
    echo "                      Options: rp2040_ce, promicro_rp2040, elite_pi, etc."
    echo "  --no-convert        Build without converter (for Pro Micro)"
    echo "  -o, --output DIR    Copy firmware to directory"
    echo "  -h, --help          Show this help message"
    echo
    echo "Environment variables:"
    echo "  VIAL_QMK_DIR        Path to vial-qmk (default: ~/git/vial-qmk)"
    echo "  KEYMAP_NAME         Keymap name (default: colemak-dh)"
    echo "  CONVERT_TO          Converter type (default: rp2040_ce)"
}

# Check prerequisites
check_prerequisites() {
    if [ ! -d "$VIAL_QMK_DIR" ]; then
        error "vial-qmk not found at $VIAL_QMK_DIR"
        error "Run ./setup.sh first or set VIAL_QMK_DIR"
        exit 1
    fi

    if ! command -v qmk &> /dev/null; then
        error "QMK CLI not found. Run ./setup.sh first"
        exit 1
    fi

    # Check if keymap is linked
    local keymap_path="$VIAL_QMK_DIR/keyboards/$KEYBOARD/keymaps/$KEYMAP_NAME"
    if [ ! -e "$keymap_path" ]; then
        warn "Keymap not found at $keymap_path"
        info "Creating symlink..."
        ln -sf "$SCRIPT_DIR" "$keymap_path"
    fi
}

# Build firmware
build_firmware() {
    local clean=$1
    local convert_to=$2

    info "Building firmware..."
    info "  Keyboard: $KEYBOARD"
    info "  Keymap: $KEYMAP_NAME"
    [ -n "$convert_to" ] && info "  Converter: $convert_to"

    cd "$VIAL_QMK_DIR"

    local cmd="qmk compile"
    [ "$clean" = true ] && cmd="$cmd -c"
    cmd="$cmd -kb $KEYBOARD -km $KEYMAP_NAME"
    [ -n "$convert_to" ] && cmd="$cmd -e CONVERT_TO=$convert_to"

    info "Running: $cmd"
    eval "$cmd"

    # Find the built firmware
    local firmware_pattern="ferris_sweep_${KEYMAP_NAME}"
    [ -n "$convert_to" ] && firmware_pattern="${firmware_pattern}_${convert_to}"
    
    local firmware_file=$(find "$VIAL_QMK_DIR" -maxdepth 1 -name "${firmware_pattern}*.uf2" -o -name "${firmware_pattern}*.hex" 2>/dev/null | head -1)
    
    if [ -n "$firmware_file" ]; then
        success "Firmware built: $firmware_file"
        echo "$firmware_file"
    else
        # Try alternate naming
        firmware_file=$(find "$VIAL_QMK_DIR" -maxdepth 1 -name "ferris_sweep_${KEYMAP_NAME}*.uf2" -o -name "ferris_sweep_${KEYMAP_NAME}*.hex" 2>/dev/null | head -1)
        if [ -n "$firmware_file" ]; then
            success "Firmware built: $firmware_file"
            echo "$firmware_file"
        fi
    fi
}

# Flash firmware
flash_firmware() {
    local side=$1
    local convert_to=$2

    info "Flashing firmware..."

    cd "$VIAL_QMK_DIR"

    local cmd="qmk flash -kb $KEYBOARD -km $KEYMAP_NAME"
    [ -n "$convert_to" ] && cmd="$cmd -e CONVERT_TO=$convert_to"

    case "$side" in
        left)
            info "Waiting for left half... Put it in bootloader mode (double-tap reset)"
            ;;
        right)
            info "Waiting for right half... Put it in bootloader mode (double-tap reset)"
            ;;
        *)
            info "Put keyboard in bootloader mode (double-tap reset)"
            ;;
    esac

    eval "$cmd"
}

# Copy firmware to output directory
copy_firmware() {
    local output_dir=$1
    local firmware_file=$2

    if [ -z "$firmware_file" ] || [ ! -f "$firmware_file" ]; then
        warn "No firmware file to copy"
        return
    fi

    mkdir -p "$output_dir"
    cp "$firmware_file" "$output_dir/"
    success "Firmware copied to: $output_dir/$(basename "$firmware_file")"
}

main() {
    local clean=false
    local flash=false
    local flash_side=""
    local convert_to="$CONVERT_TO"
    local output_dir=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--clean)
                clean=true
                shift
                ;;
            -f|--flash)
                flash=true
                shift
                ;;
            -l|--left)
                flash=true
                flash_side="left"
                shift
                ;;
            -r|--right)
                flash=true
                flash_side="right"
                shift
                ;;
            --convert-to)
                convert_to="$2"
                shift 2
                ;;
            --no-convert)
                convert_to=""
                shift
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    check_prerequisites

    if [ "$flash" = true ]; then
        flash_firmware "$flash_side" "$convert_to"
    else
        firmware_file=$(build_firmware "$clean" "$convert_to")
        
        if [ -n "$output_dir" ] && [ -n "$firmware_file" ]; then
            copy_firmware "$output_dir" "$firmware_file"
        fi
    fi
}

main "$@"
