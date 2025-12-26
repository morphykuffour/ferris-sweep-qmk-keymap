# Ferris Sweep Colemak-DH Keymap

A personalized QMK/Vial keymap for the Ferris Sweep keyboard featuring Colemak-DH layout, sm_td for home row mods, OS-aware copy/paste, mouse jiggler, and Vial support.

## Quick Start

```bash
git clone --recurse-submodules git@github.com:morphykuffour/ferris-sweep-qmk-keymap.git
cd ferris-sweep-qmk-keymap
./setup.sh
./build.sh
```

## Manual Setup

1. Install QMK dependencies - see https://docs.qmk.fm/newbs_getting_started

2. Clone vial-qmk:
```bash
git clone https://github.com/vial-kb/vial-qmk.git ~/git/vial-qmk
cd ~/git/vial-qmk
make git-submodule
```

3. Clone this keymap:
```bash
git clone --recurse-submodules git@github.com:morphykuffour/ferris-sweep-qmk-keymap.git ~/git/vial-qmk/keyboards/ferris/sweep/keymaps/colemak-dh
```

4. Build:
```bash
qmk compile -kb ferris/sweep -km colemak-dh -e CONVERT_TO=rp2040_ce
```

## Building

```bash
make build         # Build firmware
make build-clean   # Clean build  
make flash         # Flash firmware
make flash-left    # Flash left half
make flash-right   # Flash right half
make firmware      # Copy .uf2 to current dir
```

Or use build.sh directly:
```bash
./build.sh --clean                   # Clean build
./build.sh --flash                   # Flash after build
./build.sh --convert-to elite_pi    # Build for Elite-Pi
./build.sh --no-convert             # Build for Pro Micro
```

## Features

- **sm_td** - Smart Tap Dance for responsive home row mods
- **OS-aware copy/paste** - Cmd+C/V on macOS, Ctrl+C/V on Linux/Windows
- **Mouse jiggler** - Prevent screen lock
- **Shift+Backspace = Delete**
- **Raw HID** - Programmatic layer switching
- **Vial** - Real-time keymap editing

## Files

- keymap.c - Keymap with layers and custom keycodes
- config.h - Keyboard config (layers, VIAL settings)
- rules.mk - Build features
- vial.json - Vial GUI layout
- sm_td/ - Smart Tap Dance submodule
- setup.sh - Environment setup script
- build.sh - Build script
- Makefile - Convenience targets

## Resources

- https://docs.qmk.fm/
- https://get.vial.today/docs/
- https://github.com/stasmarkin/sm_td
- https://getreuer.info/posts/keyboards/
