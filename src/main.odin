package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(400, 400, "OEdit")
    defer rl.CloseWindow()

    frogTexture: rl.Texture2D = rl.LoadTexture("resources/frog.png") // Load data into VRAM (gpu)
    defer rl.UnloadTexture(frogTexture)

    rl.SetTargetFPS(60)

    log := init_outLog()
    defer writeLogToFile(&log)

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