package main

import "core:fmt"

import rl "vendor:raylib"

State :: struct {
    audioHandler: AudioHandler,
    inputHandler: InputHandler,
    spriteHandler: SpriteHandler,

    windowSize: rl.Vector2,

    dt: f32,
}

init_State :: proc(windowWidth: i32 = 400, windowHeight: i32 = 400, windowTitle: cstring = "test") -> State {
    writeFrameHeader("LOAD")

    aHandler := init_AudioHandler()
    iHandler := init_InputHandler()
    sHandler := init_SpriteHandler()

    state: State = {
        aHandler, iHandler, sHandler,
        rl.Vector2{auto_cast windowWidth, auto_cast windowHeight},
        0.0,
    }

    setStateWindow(&state, width = windowWidth, height = windowHeight, title = windowTitle)

    loadTextureToState(&state, filename = "resources/img/exception.png", tag = getStateTextureExceptionTag())
    loadSoundToState(&state, filename = "resources/sound/exception.wav", tag = getStateSoundExceptionTag())

    return state
}

destroy_State :: proc(using state: ^State) {
    writeFrameHeader("UNLOAD")

    destroy_SpriteHandler(&spriteHandler)

    destroy_InputHandler(&inputHandler)

    destroy_AudioHandler(&audioHandler)
}

setStateWindow :: proc(using state: ^State, width, height: i32, title: cstring) {
    windowSize = rl.Vector2{auto_cast width, auto_cast height}
    rl.SetWindowSize(width, height)
    rl.SetWindowTitle(title)

    writeToLog(fmt.caprintf("Set window size to (%d, %d)", width, height))
    writeToLog(fmt.caprintf("Set window title to '%s'", title))
}

loadTextureToState :: proc(using state: ^State, filename: cstring, tag: string) {
    texture := rl.LoadTexture(filename)
    writeTextureLoadToLog(tag, rl.IsTextureReady(texture))

    spriteHandler.masterSprites[tag] = texture
}

loadSoundToState :: proc(using state: ^State, filename: cstring, tag: string) {
    sound := rl.LoadSound(filename)
    writeAudioLoadToLog(tag, rl.IsSoundReady(sound))

    audioHandler.masterSounds[tag] = sound
}

loadMusicToState :: proc(using state: ^State, filename: cstring, tag: string) {
    music := rl.LoadMusicStream(filename)
    writeAudioLoadToLog(tag, rl.IsMusicReady(music))

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