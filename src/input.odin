package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

inputCallback :: proc(state: ^State, key: rl.KeyboardKey, tag: string)

InputHandler :: struct {
    keyEvents: map[string]rl.KeyboardKey,
    keyCallbacks: map[string]inputCallback,

    typingMode: bool,
    typingText: strings.Builder,
}

init_InputHandler :: proc() -> InputHandler {
    return {
        make(map[string]rl.KeyboardKey),
        make(map[string]inputCallback),

        false,
        strings.builder_make(),
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

checkInput :: proc(using handler: ^InputHandler, state: ^State) {
    if rl.IsKeyPressed(rl.KeyboardKey.TAB) do typingMode = !typingMode

    if typingMode {
        curChar := rl.GetCharPressed()
        for curChar > 0 {
            fmt.printf("%c\n", curChar)
            strings.write_rune(&typingText, curChar)
            

            curChar = rl.GetCharPressed()
        }

        if rl.IsKeyPressed(rl.KeyboardKey.BACKSPACE) do strings.pop_rune(&typingText)
        return
    }

    for tag, key in keyEvents {
        if rl.IsKeyDown(key) do keyCallbacks[tag](state, key, tag)
    }
}

getInputTypedText :: proc(using handler: InputHandler) -> cstring {
    return fmt.caprintf("%s", strings.to_string(typingText))
}