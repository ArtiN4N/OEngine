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

    loadTextureToState(&state, filename = "resources/img/frogsheet.png", tag = "frogsheet")

    newSprite := createNewSpriteAlias(
        &state.spriteHandler, 
        spriteSize = rl.Vector2{16, 16}, 
        textureSourceOffset = rl.Vector2{0, 0}, textureDestOffset = rl.Vector2{0, 0}, 
        tag = "frogsheet",
        log = &state.outLog,
    )
    
    addAnimationToSprite(
        &state.spriteHandler.spriteAliases[newSprite], 
        animationSourceOffset = rl.Vector2{0, 0}, 
        frames = 2, fps = 5, framePeriod = 2, linger = 3.0, 
        tag = "idle"
    )
    addAnimationToSprite(
        &state.spriteHandler.spriteAliases[newSprite], 
        animationSourceOffset = rl.Vector2{32, 0}, 
        frames = 3, fps = 3, framePeriod = 3, linger = 0.0, 
        tag = "smoke"
    )
    addAnimationToSprite(
        &state.spriteHandler.spriteAliases[newSprite], 
        animationSourceOffset = rl.Vector2{0, 16}, 
        frames = 5, fps = 5, framePeriod = 5, linger = -1.0, 
        tag = "jump"
    )

    ChangeSpriteAnimation(&state.spriteHandler.spriteAliases[newSprite], tag = "idle")

    writeFrameHeader(&state.outLog, "GAME")

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        checkInput(&state.inputHandler, &state)

        update_SpriteHandler(&state.spriteHandler, state.dt)
        update_AudioHandler(&state.audioHandler, state.dt)

        draw(state)
    }
}

draw :: proc(state: State) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawText(getInputTypedText(state.inputHandler), posX = 50, posY = 50, fontSize = 50, color = rl.RED)

    draw_SpriteHandler(state.spriteHandler)

    rl.DrawFPS(10, 10)
}