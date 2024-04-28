package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

// inputcallback is a procedure signature that defines how callbacks should be built
// callbacks will be automatically called when their assigned key is pressed down
inputCallback :: proc(state: ^State, key: rl.KeyboardKey, tag: string)

InputHandler :: struct {
    keyEvents: map[string]rl.KeyboardKey,
    keyCallbacks: map[string]inputCallback,

    typingMode: bool,
    typingText: strings.Builder,
}

init_InputHandler :: proc(log: ^OutLog) -> InputHandler {
    writeAllocToLog(log, varname = "inputHandler.keyEvents")
    writeAllocToLog(log, varname = "inputHandler.keyCallbacks")

    return {
        make(map[string]rl.KeyboardKey),
        make(map[string]inputCallback),

        false,
        strings.builder_make(),
    }
}

destroy_InputHandler :: proc(using handler: ^InputHandler, log: ^OutLog) {
    delete(keyEvents)
    writeAllocFreeToLog(log, varname = "inputHandler.keyEvents")

    delete(keyCallbacks)
    writeAllocFreeToLog(log, varname = "inputHandler.keyCallbacks")
}

addInputCallbackOnKey :: proc(using handler: ^InputHandler, key: rl.KeyboardKey, tag: string, callback: inputCallback) {
    keyEvents[tag] = key
    keyCallbacks[tag] = callback
}

// change a registered callback on key
changeTaggedKey :: proc(using handler: ^InputHandler, key: rl.KeyboardKey, tag: string, callback: inputCallback) {
    delete_key(&keyEvents, tag)
    delete_key(&keyCallbacks, tag)

    addInputCallbackOnKey(handler, key, tag, callback)
}

checkInput :: proc(using handler: ^InputHandler, state: ^State) {
    // placeholder method to change to typing mode
    if rl.IsKeyPressed(rl.KeyboardKey.TAB) {
        typingMode = !typingMode
        strings.builder_reset(&typingText)
    }

    if typingMode {
        // loops through the getcharpressed() queue of inputted chars
        // only takes in chars that can be displayed (i.e. no return, backspace, etc.)
        for curChar := rl.GetCharPressed(); curChar > 0; curChar = rl.GetCharPressed() do strings.write_rune(&typingText, curChar)

        if rl.IsKeyPressed(rl.KeyboardKey.BACKSPACE) do strings.pop_rune(&typingText)
        return
    }

    // trigger relevant callbacks
    for tag, key in keyEvents {
        if rl.IsKeyDown(key) do keyCallbacks[tag](state, key, tag)
    }
}

getInputTypedText :: proc(using handler: InputHandler) -> cstring {
    return fmt.caprintf("%s", strings.to_string(typingText))
}