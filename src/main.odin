package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {

    // Initializing outlog struct to log debug information
    state := init_State()
    defer cleanUpState(&state)

    rl.InitWindow(1, 1, "")
    defer rl.CloseWindow()

    setStateWindow(&state, 400, 400, "OEngine Test")

    // TEXTURES ----------------------------------

    // Creates a null texture to be auto assigned to all sprites
    loadTextureToState(&state, "resources/exception.png", "exception")

    loadTextureToState(&state, "resources/frogsheet.png", "frogsheet")

    // TODO: Change sprite to use texture pointer instead, since we dont want to be making copies of textures
    frogSprite := init_Sprite(rl.Vector2{16, 16}, &state.masterSprites["frogsheet"], rl.Vector2{0, 0}, rl.Vector2{0, 0})

    attachSpriteAnimationController(&frogSprite, &state.outLog)
    defer free_SpriteAnimationController(&frogSprite.animationController, &state.outLog)
    
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 0}, 2, 5, 2, 3.0, "idle")
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{32, 0}, 3, 3, 3, 0.0, "smoke")
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 16}, 5, 5, 5, -1.0, "jump")

    ChangeSpriteAnimation(&frogSprite.animationController, "idle")

    // -------------------------------------------

    rl.SetTargetFPS(60)

    timer: f32 = 0.0

    for !rl.WindowShouldClose() {
        setStateDT(&state)
        stepOutLog(&state.outLog, state.dt)

        timer += state.dt

        if timer < 5.0 && timer + state.dt > 5.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "smoke")
        }

        if timer < 10.0 && timer + state.dt > 10.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "jump")
        }

        if timer < 12.0 && timer + state.dt > 12.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "idle")
        }

        SpriteAnimationUpdate(&frogSprite.animationController, state.dt, &state.outLog)
        draw(frogSprite)
    }
}

draw :: proc(frogSprite: Sprite) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)
    
    drawSprite(frogSprite, 0)

    rl.DrawFPS(10, 10)
}