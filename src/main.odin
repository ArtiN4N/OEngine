package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {

    rl.InitWindow(1, 1, "")
    defer rl.CloseWindow()

    state := init_State()

    writeFrameHeader(&state.outLog, "LOAD")
    setStateWindow(&state, 400, 400, "OEngine Test")

    setUpState(&state)
    defer cleanUpState(&state)

    // Audio testing --
    createNewSoundAlias(&state.audioHandler, "coin")
    setAudioHandlerMusic(&state.audioHandler, "song", 1.0)

    followTestVector := rl.Vector2{0, 0}
    sourceTestVector := rl.Vector2{0, 0}

    attachDynamicAudioControlToMusic(
        &state.audioHandler,
        1.0,
        true, true,
        &followTestVector, &sourceTestVector,
        rl.Vector2{100, 100}, rl.Vector2{100, 100},
    )

    playAudioHandlerMusic(&state.audioHandler)
    // ------

    writeFrameHeader(&state.outLog, "GAME")

    rl.SetTargetFPS(60)

    timer: f32 = 0.0

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        timer += state.dt

        if rl.IsKeyDown(rl.KeyboardKey.A) {
            followTestVector.x -= 100 * state.dt
        }

        if rl.IsKeyDown(rl.KeyboardKey.D) {
            followTestVector.x += 100 * state.dt
        }

        if timer < 5.0 && timer + state.dt > 5.0 {
            ChangeSpriteAnimation(&state.testSprite.animationController, "smoke")

            setDyanmicPitchTargetWithSpeed(&state.audioHandler.dynamicMusicControl, 2.0, 0.1)
        }

        if timer < 10.0 && timer + state.dt > 10.0 {
            ChangeSpriteAnimation(&state.testSprite.animationController, "jump")
        }

        if timer < 12.0 && timer + state.dt > 12.0 {
            ChangeSpriteAnimation(&state.testSprite.animationController, "idle")
            
            setDyanmicPitchTargetWithSpeed(&state.audioHandler.dynamicMusicControl, 0.5, 0.1)
        }

        SpriteAnimationUpdate(&state.testSprite.animationController, state.dt, &state.outLog)
        updateAudioHandler(&state.audioHandler, state.dt)

        draw(state)
    }
}

draw :: proc(state: State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)
    
    drawSprite(state.testSprite, 0)

    rl.DrawFPS(10, 10)
}