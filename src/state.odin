package main

import "core:fmt"

import rl "vendor:raylib"

State :: struct {
    outLog: OutLog,
    audioHandler: AudioHandler,
    inputHandler: InputHandler,
    spriteHandler: SpriteHandler,

    windowSize: rl.Vector2,

    dt: f32,
}

init_State :: proc() -> State {
    log := init_OutLog()
    aHandler := init_AudioHandler(&log)
    iHandler := init_InputHandler(&log)
    sHandler := init_SpriteHandler(&log)

    state: State = {
        log, aHandler, iHandler, sHandler,
        rl.Vector2{0, 0},
        0.0,
    }

    writeFrameHeader(&state.outLog, "LOAD")

    setStateWindow(&state, width = 400, height = 400, title = "OEngine Init")

    loadTextureToState(&state, filename = "resources/img/exception.png", tag = getStateTextureExceptionTag())
    loadSoundToState(&state, filename = "resources/sound/exception.png", tag = getStateSoundExceptionTag())

    return state
}

destroy_State :: proc(using state: ^State) {
    writeFrameHeader(&outLog, "UNLOAD")

    destroy_SpriteHandler(&spriteHandler, &outLog)

    destroy_InputHandler(&inputHandler, &outLog)

    destroy_AudioHandler(&audioHandler, &outLog)

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

    spriteHandler.masterSprites[tag] = texture
}

loadSoundToState :: proc(using state: ^State, filename: cstring, tag: string) {
    sound := rl.LoadSound(filename)
    writeAudioLoadToLog(&outLog, tag, rl.IsSoundReady(sound))

    audioHandler.masterSounds[tag] = sound
}

loadMusicToState :: proc(using state: ^State, filename: cstring, tag: string) {
    music := rl.LoadMusicStream(filename)
    writeAudioLoadToLog(&outLog, tag, rl.IsMusicReady(music))

    audioHandler.masterMusic[tag] = music
}

setStateDT :: proc(using state: ^State) {
    dt = rl.GetFrameTime()
}

getStateTextureExceptionTag :: proc() -> string {
    return "exceptionTexture"
}

getStateSoundExceptionTag :: proc() -> string {
    return "exceptionSound"
}