package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {

    // Initializing outlog struct to log debug information
    log := init_OutLog()
    defer writeLogToFile(&log)

    rl.InitWindow(400, 400, "OEdit")
    defer rl.CloseWindow()

    // TEXTURES ----------------------------------

    // Creates a null texture to be auto assigned to all sprites
    exceptionTexture := rl.LoadTexture("resources/exception.png")
    writeTextureLoadToLog(&log, "resources/exception.png", rl.IsTextureReady(exceptionTexture))

    defer {
        if rl.IsTextureReady(exceptionTexture) {
            rl.UnloadTexture(exceptionTexture)
            writeDataFreeToLog(&log, "resources/exception.png")
        }
    }

    // TODO: Change sprite to use texture pointer instead, since we dont want to be making copies of textures
    frogSprite := init_Sprite(rl.Vector2{16, 16}, exceptionTexture, rl.Vector2{0, 0}, rl.Vector2{0, 0})
    
    loadSpriteTexture(&frogSprite, "resources/frogsheet.png", &log)
    defer freeSpriteTexture(&frogSprite, "resources/frogsheet.png", &log)

    attachSpriteAnimationController(&frogSprite, &log)
    defer free_SpriteAnimationController(&frogSprite.animationController, &log)
    
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 0}, 2, 5, 2, 3.0, "idle")
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{32, 0}, 3, 3, 3, 0.0, "smoke")
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 16}, 5, 5, 5, -1.0, "jump")

    ChangeSpriteAnimation(&frogSprite.animationController, "idle")

    // -------------------------------------------

    rl.SetTargetFPS(60)

    timer: f32 = 0.0

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        stepOutLog(&log, dt)

        timer += dt

        if timer < 5.0 && timer + dt > 5.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "smoke")
        }

        if timer < 10.0 && timer + dt > 10.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "jump")
        }

        if timer < 12.0 && timer + dt > 12.0 {
            ChangeSpriteAnimation(&frogSprite.animationController, "idle")
        }

        SpriteAnimationUpdate(&frogSprite.animationController, dt, &log)
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