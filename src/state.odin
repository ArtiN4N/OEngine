package main

import "core:fmt"

import rl "vendor:raylib"

State :: struct {
    outLog: OutLog,
    windowSize: rl.Vector2,

    dt: f32,

    masterSprites: map[string]rl.Vector2,   
}

init_State :: proc() -> State {
    return {
        init_OutLog(), rl.Vector2{0, 0},
        0.0,
        make(map[string]rl.Vector2)
    }
}

cleanUpState :: proc(using state: ^State) {
    writeLogToFile(&outLog)
}

setStateWindow :: proc(using state: ^State, width, height: i32, title: cstring) {
    windowSize = rl.Vector2{auto_cast width, auto_cast height}
    rl.SetWindowSize(width, height)
    rl.SetWindowTitle(title)

    writeToLog(&outLog, fmt.tprintf("Set window size to (%d, %d)", width, height))
    writeToLog(&outLog, fmt.tprintf("Set window title to '%s'", title))
}

setStateDT :: proc(using state: ^State) {
    dt = rl.GetFrameTime()
}