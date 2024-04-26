package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {

    rl.InitWindow(1, 1, "")
    defer rl.CloseWindow()

    state := init_State()

    setUpState(&state)
    defer cleanUpState(&state)

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        checkInput(&state.inputHandler, &state)

        SpriteAnimationUpdate(&state.testSprite.animationController, state.dt, &state.outLog)
        updateAudioHandler(&state.audioHandler, state.dt)

        draw(state)
    }
}

draw :: proc(state: State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawText(getInputTypedText(state.inputHandler), 50, 50, 50, rl.RED)

    rl.DrawFPS(10, 10)
}