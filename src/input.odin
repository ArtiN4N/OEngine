package main

import "core:fmt"

import rl "vendor:raylib"

inputCallback :: proc(state: ^State)

InputHandler :: struct {
    keyEvents: map[string]rl.KeyboardKey,
    keyCallbacks: map[string]inputCallback,
}

init_InputHandler :: proc() -> InputHandler {
    return {
        make(map[string]rl.KeyboardKey),
        make(map[string]inputCallback),
    }
}

addInputCallbackOnKeyPress :: proc(using handler: ^InputHandler, key: rl.KeyboardKey, tag: string, callback: inputCallback) {
    keyEvents[tag] = key
    keyCallbacks[tag] = callback
}

checkInput :: proc(using handler: InputHandler, state: ^State) {
    for tag, key in keyEvents {
        if rl.IsKeyPressed(key) do keyCallbacks[tag](state)
    }
}