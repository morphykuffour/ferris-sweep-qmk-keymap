# Ferris Sweep QMK Keymap Makefile

VIAL_QMK_DIR ?= $(HOME)/git/vial-qmk
KEYBOARD := ferris/sweep
KEYMAP_NAME ?= colemak-dh
CONVERT_TO ?= rp2040_ce

.PHONY: all setup build clean flash help

all: build

setup:
	@./setup.sh

setup-quick:
	@./setup.sh --skip-deps

build:
	@./build.sh

build-clean:
	@./build.sh --clean

build-promicro:
	@./build.sh --no-convert

build-elite-pi:
	@./build.sh --convert-to elite_pi

flash:
	@./build.sh --flash

flash-left:
	@./build.sh --left

flash-right:
	@./build.sh --right

submodules:
	git submodule update --init --recursive

update-smtd:
	git submodule update --remote sm_td

firmware:
	@./build.sh --output .

clean:
	cd $(VIAL_QMK_DIR) && make clean

help:
	@echo "Targets: setup, build, flash, flash-left, flash-right, firmware, clean"
