package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

aPressCallback :: proc(state: ^State, key: rl.KeyboardKey, tag: string) {
    state.counter += 1
}

main :: proc() {

    rl.InitWindow(1, 1, "")
    defer rl.CloseWindow()

    state := init_State()

    writeFrameHeader(&state.outLog, "LOAD")
    setStateWindow(&state, 400, 400, "OEngine Test")

    setUpState(&state)
    defer cleanUpState(&state)

    writeFrameHeader(&state.outLog, "GAME")

    // input --
    addInputCallbackOnKey(&state.inputHandler, rl.KeyboardKey.A, "apress", aPressCallback)
    // -----------------

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        checkInput(state.inputHandler, &state)

        SpriteAnimationUpdate(&state.testSprite.animationController, state.dt, &state.outLog)
        updateAudioHandler(&state.audioHandler, state.dt)

        draw(state)
    }
}

draw :: proc(state: State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawText(fmt.caprintf("Counter = %d", state.counter), 50, 50, 50, rl.RED)

    rl.DrawFPS(10, 10)
}