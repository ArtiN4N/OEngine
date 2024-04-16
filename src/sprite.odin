package main

import "core:strings"

import rl "vendor:raylib"

Sprite :: struct {
    animated: bool,

    frames: int,
    curFrame: int,
    // Describes how many frames should be read from the spritesheet from a specific row until the row is pushed downwards.
    // If framePeriod == frames, then all frames of a sprite exist on the same spritesheet row
    framePeriod: int,
    frameSize: rl.Vector2,

    texture: rl.Texture2D,
    textureSourceOffset: rl.Vector2,
    textureDestOffset: rl.Vector2,

    textureLoaded: bool,
}

init_Sprite :: proc(
    animated: bool, 
    frames, framePeriod: int, frameSize: rl.Vector2,
    texture: rl.Texture2D, textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2
) -> Sprite {
    return {
        animated,
        frames, 0, framePeriod, frameSize,
        texture, textureSourceOffset, textureDestOffset,
        
        false,
    }
}

getSpriteSourceRec :: proc(using sprite: Sprite) -> rl.Rectangle {
    return rl.Rectangle{
        textureSourceOffset.x + frameSize.x * auto_cast (curFrame % framePeriod), textureSourceOffset.y + frameSize.y * auto_cast (curFrame / framePeriod), 
        frameSize.x, frameSize.y,
    }
}

loadSpriteTexture :: proc(using sprite: ^Sprite, filename: string, log: ^OutLog) {
    texture = rl.LoadTexture(strings.clone_to_cstring(filename))
    textureLoaded = rl.IsTextureReady(texture)
    writeTextureLoadToLog(log, filename, textureLoaded)
}

freeSpriteTexture :: proc(using sprite: ^Sprite, filename: string, log: ^OutLog) {
    if !textureLoaded {
        writeToLog(log, "ERROR - Tried to free sprite that was never loaded!\n")
        return
    }

    rl.UnloadTexture(texture)
    writeDataFreeToLog(log, filename)
}