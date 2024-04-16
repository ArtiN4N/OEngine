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

    frogSprite := init_Sprite(false, 1, 1, rl.Vector2{0, 0}, exceptionTexture, rl.Rectangle{0, 0, 0, 0})
    loadSpriteTexture(&frogSprite, "resources/frog.png", &log)

    defer freeSpriteTexture(&frogSprite, "resources/frog.png", &log)

    // -------------------------------------------

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        draw(frogSprite)
    }
}

draw :: proc(frogSprite: Sprite) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawTexture(frogSprite.texture, 20, 20, rl.RAYWHITE)

    rl.DrawFPS(10, 10)
}