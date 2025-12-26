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
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/arch-release ]; then
                echo "arch"
            elif [ -f /etc/debian_version ]; then
                echo "debian"
            elif [ -f /etc/fedora-release ]; then
                echo "fedora"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Install system dependencies
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
                avr-libc gcc-avr avrdude \
                dfu-util dfu-programmer
            ;;
        fedora)
            info "Installing dependencies via dnf..."
            sudo dnf install -y \
                git python3 python3-pip \
                arm-none-eabi-gcc-cs arm-none-eabi-newlib \
                avr-gcc avr-libc avrdude \
                dfu-util dfu-programmer
            ;;
        macos)
            info "Installing dependencies via Homebrew..."
            if ! command -v brew &> /dev/null; then
                error "Homebrew not found. Please install it first: https://brew.sh"
                exit 1
            fi
            brew install python git
            brew tap osx-cross/avr
            brew tap osx-cross/arm
            brew install avr-gcc arm-none-eabi-gcc avrdude dfu-util
            ;;
        *)
            warn "Unknown OS. Please install dependencies manually:"
            warn "  - git, python3, python3-pip"
            warn "  - arm-none-eabi-gcc toolchain"
            warn "  - avr-gcc toolchain"
            warn "  - dfu-util, avrdude"
            ;;
    esac
}

# Install QMK CLI
install_qmk_cli() {
    info "Installing QMK CLI..."
    python3 -m pip install --user --upgrade qmk
    
    # Add to PATH if not already there
    local pip_bin="$HOME/.local/bin"
    if [[ ":$PATH:" != *":$pip_bin:"* ]]; then
        warn "Adding $pip_bin to PATH in your shell rc file..."
        for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [ -f "$rc" ]; then
                if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
                fi
            fi
        done
        export PATH="$pip_bin:$PATH"
    fi
}

# Clone or update vial-qmk
setup_vial_qmk() {
    if [ -d "$VIAL_QMK_DIR" ]; then
        info "vial-qmk directory exists at $VIAL_QMK_DIR"
        read -p "Update existing repo? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Updating vial-qmk..."
            cd "$VIAL_QMK_DIR"
            git pull --ff-only || warn "Could not fast-forward, you may have local changes"
            make git-submodule
        fi
    else
        info "Cloning vial-qmk to $VIAL_QMK_DIR..."
        mkdir -p "$(dirname "$VIAL_QMK_DIR")"
        git clone "$VIAL_QMK_REPO" "$VIAL_QMK_DIR"
        cd "$VIAL_QMK_DIR"
        info "Initializing submodules (this may take a while)..."
        make git-submodule
    fi
}

# Link keymap to vial-qmk
link_keymap() {
    local keymap_dest="$VIAL_QMK_DIR/keyboards/$KEYBOARD/keymaps/$KEYMAP_NAME"
    
    if [ -L "$keymap_dest" ]; then
        info "Keymap symlink already exists"
        return
    fi
    
    if [ -d "$keymap_dest" ]; then
        warn "Keymap directory already exists at $keymap_dest"
        read -p "Replace with symlink to this repo? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$keymap_dest"
        else
            return
        fi
    fi
    
    info "Creating symlink: $keymap_dest -> $SCRIPT_DIR"
    mkdir -p "$(dirname "$keymap_dest")"
    ln -sf "$SCRIPT_DIR" "$keymap_dest"
    success "Keymap linked successfully"
}

# Initialize sm_td submodule
init_submodules() {
    info "Initializing submodules (sm_td)..."
    cd "$SCRIPT_DIR"
    git submodule update --init --recursive
    success "Submodules initialized"
}

# Configure QMK
configure_qmk() {
    info "Configuring QMK..."
    qmk config user.qmk_home="$VIAL_QMK_DIR" || true
    qmk config user.keyboard="$KEYBOARD" || true
    qmk config user.keymap="$KEYMAP_NAME" || true
}

# Main setup
main() {
    echo "========================================"
    echo " Ferris Sweep QMK Keymap Setup"
    echo "========================================"
    echo

    # Parse arguments
    local skip_deps=false
    local skip_clone=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --skip-clone)
                skip_clone=true
                shift
                ;;
            --vial-qmk-dir)
                VIAL_QMK_DIR="$2"
                shift 2
                ;;
            --keymap-name)
                KEYMAP_NAME="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo
                echo "Options:"
                echo "  --skip-deps       Skip installing system dependencies"
                echo "  --skip-clone      Skip cloning vial-qmk (use existing)"
                echo "  --vial-qmk-dir    Set vial-qmk directory (default: ~/git/vial-qmk)"
                echo "  --keymap-name     Set keymap name (default: colemak-dh)"
                echo "  -h, --help        Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    if [ "$skip_deps" = false ]; then
        install_dependencies
    fi

    install_qmk_cli

    if [ "$skip_clone" = false ]; then
        setup_vial_qmk
    fi

    init_submodules
    link_keymap
    configure_qmk

    echo
    success "Setup complete!"
    echo
    echo "To build firmware, run:"
    echo "  ./build.sh"
    echo
    echo "Or manually:"
    echo "  cd $VIAL_QMK_DIR"
    echo "  qmk compile -kb $KEYBOARD -km $KEYMAP_NAME -e CONVERT_TO=rp2040_ce"
}

main "$@"
