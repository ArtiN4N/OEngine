package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {

    rl.InitWindow(1, 1, "")
    defer rl.CloseWindow()

    state := init_State()
    defer destroy_State(&state)

    rl.SetTargetFPS(60)

    loadTextureToState(&state, "resources/img/frogsheet.png", "frogsheet")

    newSprite := createNewSpriteAlias(&state.spriteHandler, rl.Vector2{16, 16}, rl.Vector2{0, 0}, rl.Vector2{0, 0}, "frogsheet", &state.outLog)
    
    addAnimationToSprite(&state.spriteHandler.spriteAliases[newSprite], rl.Vector2{0, 0}, 2, 5, 2, 3.0, "idle")
    addAnimationToSprite(&state.spriteHandler.spriteAliases[newSprite], rl.Vector2{32, 0}, 3, 3, 3, 0.0, "smoke")
    addAnimationToSprite(&state.spriteHandler.spriteAliases[newSprite], rl.Vector2{0, 16}, 5, 5, 5, -1.0, "jump")

    ChangeSpriteAnimation(&state.spriteHandler.spriteAliases[newSprite], "idle")

    writeFrameHeader(&state.outLog, "GAME")

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        checkInput(&state.inputHandler, &state)

        update_SpriteHandler(&state.spriteHandler, state.dt)
        updateAudioHandler(&state.audioHandler, state.dt)

        draw(state)
    }
}

draw :: proc(state: State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawText(getInputTypedText(state.inputHandler), 50, 50, 50, rl.RED)

    draw_SpriteHandler(state.spriteHandler)

    rl.DrawFPS(10, 10)
}