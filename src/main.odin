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

    // Creates a null texture
    exceptionTexture := rl.LoadTexture("resources/exception.png")
    writeTextureLoadToLog(&log, "resources/exception.png", rl.IsTextureReady(exceptionTexture))
    defer {
        if rl.IsTextureReady(exceptionTexture) {
            rl.UnloadTexture(exceptionTexture)
            writeDataFreeToLog(&log, "resources/exception.png")
        }
    }

    frogSprite := init_Sprite(rl.Vector2{700, 448}, exceptionTexture, rl.Vector2{0, 0}, rl.Vector2{0, 0})
    
    loadSpriteTexture(&frogSprite, "resources/frog.png", &log)
    defer freeSpriteTexture(&frogSprite, "resources/frog.png", &log)

    attachSpriteAnimationController(&frogSprite, 2, &log)
    defer free_SpriteAnimationController(&frogSprite.animationController, &log)
    
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 0}, 2, 2, "upper")
    addAnimationToSpriteController(&frogSprite.animationController, rl.Vector2{0, 448}, 2, 2, "lower")

    // -------------------------------------------

    rl.SetTargetFPS(60)

    timer: f32 = 0.0

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        timer += dt

        if timer >= 2.0 {
            frogSprite.animationController.currentAnimation = &frogSprite.animationController.animations["upper"]
        }

        SpriteAnimationUpdate(&frogSprite.animationController, dt, &log)
        draw(frogSprite)
    }
}

draw :: proc(frogSprite: Sprite) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)
    
    rl.DrawTexturePro(
        frogSprite.texture, 
        getSpriteSourceRec(frogSprite), 
        rl.Rectangle{100, 100, 260, 200}, 
        frogSprite.textureDestOffset, 
        0,
        rl.RAYWHITE
    )

    rl.DrawFPS(10, 10)
}