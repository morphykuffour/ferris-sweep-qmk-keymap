// this is the style you want to emulate.
// This is the canonical layout file for the Quantum project. If you want to add another keyboard,

#include QMK_KEYBOARD_H

enum custom_keycodes {
    SMTD_KEYCODES_BEGIN = SAFE_RANGE,
    CKC_Z, // reads as C(ustom) + KC_A
    CKC_X,
    CKC_C,
    CKC_D,
    CKC_H,
    CKC_COMM,
    CKC_DOT,
    CKC_SLSH,
    CKC_CLGV,
    CKC_GUTA,
    SMTD_KEYCODES_END,
};

#include "sm_td/sm_td.h"

#define MEH_SPACE MT(MOD_MEH, KC_SPACE)
// alternative
// MEH_T(kc)		Left Control, Shift and Alt when held, kc when tapped

// Layer 1: SMTD_LT(CKC_CLGV, KC_GRV, 1)
// Layer 2: SMTD_LT(CKC_GUTA, KC_TAB, 2)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT(
    KC_Q,    KC_W,    KC_F,    KC_P,    KC_B,            KC_J,    KC_L,  KC_U,    KC_Y,   KC_SCLN,
    KC_A,    KC_R,    KC_S,    KC_T,    KC_G,            KC_M,    KC_N,  KC_E,    KC_I,   KC_O,
    CKC_Z,   CKC_X,   CKC_C,   CKC_D,    KC_V,           KC_K,    CKC_H, CKC_COMM,CKC_DOT,CKC_SLSH,
                                  CKC_CLGV, KC_BSPC,  MEH_SPACE, CKC_GUTA
  ),

  [1] = LAYOUT(
    KC_1,    KC_2,    KC_3,    KC_4,    KC_5,            KC_6,    KC_7,    KC_8,    KC_9,    KC_0,
    QK_GESC, KC_HOME, KC_PGDN, KC_PGUP, KC_END,          KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_QUOT,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_BTN1, KC_BTN2,         KC_MS_L, KC_MS_D, KC_MS_U, KC_MS_R, KC_ENT,
                                    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
  ),

  [2] = LAYOUT(
    KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,           KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,
    KC_TAB,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,         KC_MINS, KC_EQL,  KC_LBRC, KC_RBRC, KC_PIPE,
    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,         KC_UNDS, KC_PLUS, KC_TRNS, KC_TRNS, QK_BOOT,
                                    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
  ),

  [3] = LAYOUT(
    KC_TRNS,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,         KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
    KC_TRNS,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,         KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
    KC_TRNS,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,         KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
                                    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
  ),
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!process_smtd(keycode, record)) {
        return false;
    }
    // your code here
    return true;  // Default return value if process_smtd returns true
}

void on_smtd_action(uint16_t keycode, smtd_action action, uint8_t tap_count) {
    switch (keycode) {
        SMTD_MT(CKC_Z, KC_Z, KC_LEFT_GUI)
        SMTD_MT(CKC_X, KC_X, KC_LEFT_ALT)
        SMTD_MT(CKC_C, KC_C, KC_LEFT_CTRL)
        SMTD_MT(CKC_D, KC_D, KC_LSFT)

        SMTD_MT(CKC_SLSH, KC_SLSH, KC_LEFT_GUI)
        SMTD_MT(CKC_DOT, KC_DOT, KC_LEFT_ALT)
        SMTD_MT(CKC_COMM, KC_COMM, KC_LEFT_CTRL)
        SMTD_MT(CKC_H, KC_H, KC_LSFT)

        SMTD_LT(CKC_CLGV, KC_GRV, 1)
        SMTD_LT(CKC_GUTA, KC_TAB, 2)


        // SMTD_MT(CKC_SPACE, KC_SPACE, MOD_MEH)
    }
}

// compile
// qmk compile -c -kb ferris/sweep -km colemak-dh -e CONVERT_TO=rp2040_ce
// qmk compile -c -kb ferris/sweep -km vial -e CONVERT_TO=rp2040_ce
