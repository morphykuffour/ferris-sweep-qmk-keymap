## Getting Started
[Setup build environment](https://docs.qmk.fm/newbs_getting_started#set-up-your-environment)

Run QMK Setup
```bash
qmk setup
```

Clone qmk-vial repo
```bash
mkdir ~/git
git clone https://github.com/vial-kb/vial-qmk.git ~/git/vial-qmk
cd ~/git/vial-qmk
```

Clone this repo into ferris sweep keymaps directory
```bash
git clone --recurse-submodules https://github.com/morphykuffour/ferris-sweep-qmk-keymap.git ~/git/vial-qmk/keyboards/ferris/sweep/keymaps/colemak-dh
```

Compile
```bash
qmk compile -c -kb ferris/sweep -km colemak-dh -e CONVERT_TO=rp2040_ce
```

## Features
This keymap utilizes stasmarkin's sm_td user library for QMK for handling tap dance.
