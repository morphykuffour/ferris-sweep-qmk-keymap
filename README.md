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

Pull submodules into qmk-vial directory
```bash
cd ~/git/vial-qmk
make git-submodule
```

Clone this repo into ferris sweep keymaps directory
```bash
git clone --recurse-submodules git@github.com:morphykuffour/ferris-sweep-qmk-keymap.git ~/git/vial-qmk/keyboards/ferris/sweep/keymaps/colemak-dh
```

Compile
```bash
qmk compile -c -kb ferris/sweep -km colemak-dh -e CONVERT_TO=rp2040_ce
```

## Features
This keymap utilizes stasmarkin's sm_td user library for QMK for handling tap dance.

This keymap includes Shift + Backspace = Delete from [Pascal Getreuer](https://getreuer.info/posts/keyboards/macros3/index.html)

This keymap has copy and paste keycodes that are os agnostic. See keymap.c
