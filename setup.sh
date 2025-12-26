#!/usr/bin/env bash
#
# Ferris Sweep QMK Keymap Setup Script
# This script sets up the complete QMK/Vial build environment
#

set -euo pipefail

# Configuration
VIAL_QMK_REPO="https://github.com/vial-kb/vial-qmk.git"
VIAL_QMK_DIR="${VIAL_QMK_DIR:-$HOME/git/vial-qmk}"
KEYBOARD="ferris/sweep"
KEYMAP_NAME="${KEYMAP_NAME:-colemak-dh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/arch-release ]; then echo "arch"
            elif [ -f /etc/debian_version ]; then echo "debian"
            elif [ -f /etc/fedora-release ]; then echo "fedora"
            else echo "linux"; fi
            ;;
        Darwin*) echo "macos" ;;
        *) echo "unknown" ;;
    esac
}

install_dependencies() {
    local os=$(detect_os)
    info "Detected OS: $os"

    case "$os" in
        arch)
            info "Installing dependencies via pacman..."
            sudo pacman -S --needed --noconfirm \
                git python python-pip \
                arm-none-eabi-gcc arm-none-eabi-newlib \
                avr-gcc avr-libc avrdude \
                dfu-util dfu-programmer
            ;;
        debian)
            info "Installing dependencies via apt..."
            sudo apt-get update
            sudo apt-get install -y \
                git python3 python3-pip python3-venv \
                gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi \
                avr-libc gcc-avr avrdude dfu-util dfu-programmer
            ;;
        fedora)
            info "Installing dependencies via dnf..."
            sudo dnf install -y \
                git python3 python3-pip \
                arm-none-eabi-gcc-cs arm-none-eabi-newlib \
                avr-gcc avr-libc avrdude dfu-util dfu-programmer
            ;;
        macos)
            info "Installing dependencies via Homebrew..."
            if ! command -v brew &> /dev/null; then
                error "Homebrew not found. Install from https://brew.sh"
                exit 1
            fi
            brew install python git pipx
            brew tap osx-cross/avr
            brew tap osx-cross/arm
            brew install avr-gcc arm-none-eabi-gcc avrdude dfu-util
            pipx ensurepath
            ;;
        *)
            warn "Unknown OS. Install manually: git, python3, arm-none-eabi-gcc, avr-gcc, dfu-util"
            ;;
    esac
}

install_qmk_cli() {
    info "Installing QMK CLI..."
    local os=$(detect_os)

    if [ "$os" = "macos" ]; then
        if ! command -v pipx &> /dev/null; then
            info "Installing pipx..."
            brew install pipx
            pipx ensurepath
            export PATH="$HOME/.local/bin:$PATH"
        fi
        if command -v qmk &> /dev/null; then
            info "QMK already installed, upgrading..."
            pipx upgrade qmk 2>/dev/null || true
        else
            pipx install qmk
        fi
    else
        python3 -m pip install --user --upgrade qmk
        local pip_bin="$HOME/.local/bin"
        if [[ ":$PATH:" != *":$pip_bin:"* ]]; then
            export PATH="$pip_bin:$PATH"
            for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
                [ -f "$rc" ] && ! grep -q '.local/bin' "$rc" && \
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            done
        fi
    fi
    success "QMK CLI installed"
}

setup_vial_qmk() {
    if [ -d "$VIAL_QMK_DIR" ]; then
        info "vial-qmk exists at $VIAL_QMK_DIR"
        info "Ensuring submodules are initialized..."
        cd "$VIAL_QMK_DIR"
        make git-submodule
    else
        info "Cloning vial-qmk to $VIAL_QMK_DIR..."
        mkdir -p "$(dirname "$VIAL_QMK_DIR")"
        git clone "$VIAL_QMK_REPO" "$VIAL_QMK_DIR"
        cd "$VIAL_QMK_DIR"
        info "Initializing submodules (this takes a while)..."
        make git-submodule
    fi
    success "vial-qmk ready"
}

link_keymap() {
    local keymap_dest="$VIAL_QMK_DIR/keyboards/$KEYBOARD/keymaps/$KEYMAP_NAME"

    if [ -L "$keymap_dest" ]; then
        info "Keymap symlink exists"
        return
    fi

    [ -d "$keymap_dest" ] && rm -rf "$keymap_dest"

    info "Linking keymap: $keymap_dest -> $SCRIPT_DIR"
    mkdir -p "$(dirname "$keymap_dest")"
    ln -sf "$SCRIPT_DIR" "$keymap_dest"
    success "Keymap linked"
}

init_submodules() {
    info "Initializing sm_td submodule..."
    cd "$SCRIPT_DIR"
    git submodule update --init --recursive
    success "Submodules ready"
}

configure_qmk() {
    info "Configuring QMK..."
    qmk config user.qmk_home="$VIAL_QMK_DIR" 2>/dev/null || true
    qmk config user.keyboard="$KEYBOARD" 2>/dev/null || true
    qmk config user.keymap="$KEYMAP_NAME" 2>/dev/null || true
}

main() {
    echo "========================================"
    echo " Ferris Sweep QMK Keymap Setup"
    echo "========================================"
    echo

    local skip_deps=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps) skip_deps=true; shift ;;
            --vial-qmk-dir) VIAL_QMK_DIR="$2"; shift 2 ;;
            --keymap-name) KEYMAP_NAME="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: $0 [--skip-deps] [--vial-qmk-dir DIR] [--keymap-name NAME]"
                exit 0 ;;
            *) error "Unknown option: $1"; exit 1 ;;
        esac
    done

    [ "$skip_deps" = false ] && install_dependencies
    install_qmk_cli
    setup_vial_qmk
    init_submodules
    link_keymap
    configure_qmk

    echo
    success "Setup complete!"
    echo
    echo "Build firmware: ./build.sh"
    echo "Or: cd $VIAL_QMK_DIR && qmk compile -kb $KEYBOARD -km $KEYMAP_NAME -e CONVERT_TO=rp2040_ce"
}

main "$@"
