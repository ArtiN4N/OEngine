package main

import "core:fmt"

import rl "vendor:raylib"

inputCallback :: proc(state: ^State, key: rl.KeyboardKey, tag: string)

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

addInputCallbackOnKey :: proc(using handler: ^InputHandler, key: rl.KeyboardKey, tag: string, callback: inputCallback) {
    keyEvents[tag] = key
    keyCallbacks[tag] = callback
}

changeTaggedKey :: proc(using handler: ^InputHandler, key: rl.KeyboardKey, tag: string, callback: inputCallback) {
    delete_key(&keyEvents, tag)
    delete_key(&keyCallbacks, tag)

    addInputCallbackOnKey(handler, key, tag, callback)
}

checkInput :: proc(using handler: InputHandler, state: ^State) {
    for tag, key in keyEvents {
        if rl.IsKeyDown(key) do keyCallbacks[tag](state, key, tag)
    }
}