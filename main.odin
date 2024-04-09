package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(400, 400, "OEdit")
    defer rl.CloseWindow()

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