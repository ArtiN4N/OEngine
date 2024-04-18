package main

import "core:fmt"

import rl "vendor:raylib"

State :: struct {
    outLog: OutLog,
    windowSize: rl.Vector2,

    dt: f32,

    masterSprites: map[string]rl.Texture2D,   
}

init_State :: proc() -> State {
    return {
        init_OutLog(), rl.Vector2{0, 0},
        0.0,
        make(map[string]rl.Texture2D)
    }
}

cleanUpState :: proc(using state: ^State) {
    writeFrameHeader(&outLog, "UNLOAD")
    
    for tag, texture in masterSprites {
        writeDataFreeToLog(&outLog, tag)
        rl.UnloadTexture(texture)
    }

    writeLogToFile(&outLog)
}

setStateWindow :: proc(using state: ^State, width, height: i32, title: cstring) {
    windowSize = rl.Vector2{auto_cast width, auto_cast height}
    rl.SetWindowSize(width, height)
    rl.SetWindowTitle(title)

    writeToLog(&outLog, fmt.tprintf("Set window size to (%d, %d)", width, height))
    writeToLog(&outLog, fmt.tprintf("Set window title to '%s'", title))
}

loadTextureToState :: proc(using state: ^State, filename: cstring, tag: string) {
    texture := rl.LoadTexture(filename)
    writeTextureLoadToLog(&outLog, tag, rl.IsTextureReady(texture))

    masterSprites[tag] = texture
}

setStateDT :: proc(using state: ^State) {
    dt = rl.GetFrameTime()
}