package main

import "core:fmt"

import rl "vendor:raylib"

State :: struct {
    outLog: OutLog,
    audioHandler: AudioHandler,

    windowSize: rl.Vector2,

    dt: f32,

    masterSprites: map[string]rl.Texture2D,

    testSprite: Sprite,
}

init_State :: proc() -> State {
    return {
        init_OutLog(), init_AudioHandler(),
        rl.Vector2{0, 0},
        0.0,
        make(map[string]rl.Texture2D),
        init_Sprite(rl.Vector2{0, 0}, nil, rl.Vector2{0, 0}, rl.Vector2{0, 0})
    }
}

setUpState :: proc(using state: ^State) {
    loadTextureToState(state, "resources/exception.png", "exception")
    loadTextureToState(state, "resources/frogsheet.png", "frogsheet")

    // testing sprite --
    testSprite = init_Sprite(rl.Vector2{16, 16}, &masterSprites["frogsheet"], rl.Vector2{0, 0}, rl.Vector2{0, 0})

    attachSpriteAnimationController(&testSprite, &state.outLog)

    addAnimationToSpriteController(&testSprite.animationController, rl.Vector2{0, 0}, 2, 5, 2, 3.0, "idle")
    addAnimationToSpriteController(&testSprite.animationController, rl.Vector2{32, 0}, 3, 3, 3, 0.0, "smoke")
    addAnimationToSpriteController(&testSprite.animationController, rl.Vector2{0, 16}, 5, 5, 5, -1.0, "jump")

    ChangeSpriteAnimation(&testSprite.animationController, "idle")
    // -----------------
}

cleanUpState :: proc(using state: ^State) {
    writeFrameHeader(&outLog, "UNLOAD")

    // TEXTURES
    free_SpriteAnimationController(&testSprite.animationController, &state.outLog)
    
    for tag, texture in masterSprites {
        writeDataFreeToLog(&outLog, tag)
        rl.UnloadTexture(texture)
    }

    // AUDIO
    cleanUpAudioHandler(&audioHandler)

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