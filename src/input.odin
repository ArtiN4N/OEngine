package main

import "core:fmt"

import rl "vendor:raylib"

InputHandler :: struct {
    keyEvents: map[string]rl.KeyboardKey,
}