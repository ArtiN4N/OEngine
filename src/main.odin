package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {
    // Initializing outlog struct to log debug information
    log := init_outLog()
    defer writeLogToFile(&log)

    rl.InitWindow(400, 400, "OEdit")
    defer rl.CloseWindow()

    // TEXTURES ----------------------------------
    frogTexture: rl.Texture2D = rl.LoadTexture("resources/frog.png") // Load data into VRAM (gpu)

    writeTextureLoadToLog(&log, "resources/frog.png")
    defer writeDataFreeToLog(&log, "resources/frog.png")

    defer rl.UnloadTexture(frogTexture)
    // -------------------------------------------

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        draw()
    }
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    rl.DrawFPS(10, 10)
}