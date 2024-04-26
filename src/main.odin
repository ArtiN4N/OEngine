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

    writeFrameHeader(&state.outLog, "GAME")

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        if rl.IsKeyDown(rl.KeyboardKey.A) {
            followTestVector.x -= 100 * state.dt
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

    rl.DrawFPS(10, 10)
}