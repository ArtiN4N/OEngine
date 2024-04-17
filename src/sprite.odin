package main

import "core:strings"

import rl "vendor:raylib"

SpriteAnimation :: struct {
    animationSourceOffset: rl.Vector2,
    frames: int,
    // Describes how many frames should be read from the spritesheet from a specific row until the row is pushed downwards.
    // If framePeriod == frames, then all frames of a sprite exist on the same spritesheet row
    framePeriod: int,
    tag: string
}

init_SpriteAnimation :: proc(animationSourceOffset: rl.Vector2, frames: int, framePeriod: int, tag: string) -> SpriteAnimation {
    return {
        animationSourceOffset, frames, framePeriod, tag
    }
}

SpriteAnimationController :: struct {
    animations: map[string]SpriteAnimation,
    currentAnimation: ^SpriteAnimation,

    fps: int,
    curFrame: int,
    curTime: f32,
}

init_SpriteAnimationController :: proc(fps: int) -> SpriteAnimationController {
    return {
        make(map[string]SpriteAnimation), nil,
        fps, 0, 0.0
    }
}

free_SpriteAnimationController :: proc(using controller: ^SpriteAnimationController, log: ^OutLog) {
    writeAllocFreeToLog(log, "SpriteAnimationController.animations")
    delete(animations)
}

addAnimationToSpriteController :: proc(
    using controller: ^SpriteAnimationController, 
    animationSourceOffset: rl.Vector2, frames: int, framePeriod: int,
    tag: string
) {
    animations[tag] = init_SpriteAnimation(animationSourceOffset, frames, framePeriod, tag)
    currentAnimation = &animations[tag]
}

SpriteAnimationUpdate :: proc(using controller: ^SpriteAnimationController, dt: f32, log: ^OutLog) {
    if currentAnimation == nil {
        writeToLog(log, "ERROR - tried to update a sprite without an animation")
        return
    }

    curTime += dt

    if curTime >= 1.0 / auto_cast fps {
        curTime = 0.0
        curFrame += 1

        if curFrame >= currentAnimation.frames {
            curFrame = 0
        }
    }
}

Sprite :: struct {
    animated: bool,
    animationController: SpriteAnimationController,

    spriteSize: rl.Vector2,

    texture: rl.Texture2D,
    textureSourceOffset: rl.Vector2,
    textureDestOffset: rl.Vector2,

    textureLoaded: bool,
}

init_Sprite :: proc(
    spriteSize: rl.Vector2,
    texture: rl.Texture2D, textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2
) -> Sprite {
    return {
        false, init_SpriteAnimationController(0),
        spriteSize,
        texture, textureSourceOffset, textureDestOffset,
        
        false,
    }
}

attachSpriteAnimationController :: proc(using sprite: ^Sprite, fps: int, log: ^OutLog) {
    animated = true;
    animationController = init_SpriteAnimationController(fps)
    writeAllocToLog(log, "SpriteAnimationController.animations")
}

getFrameSourcePosition :: proc(using sprite: Sprite) -> (f32, f32) {
    x := textureSourceOffset.x
    y := textureSourceOffset.y
    
    if animated && animationController.currentAnimation != nil {
        x += animationController.currentAnimation.animationSourceOffset.x
        y += animationController.currentAnimation.animationSourceOffset.y

        x += spriteSize.x * auto_cast (animationController.curFrame % animationController.currentAnimation.framePeriod)
        y += spriteSize.y * auto_cast (animationController.curFrame / animationController.currentAnimation.framePeriod)
    }

    return x, y
}

getSpriteSourceRec :: proc(using sprite: Sprite) -> rl.Rectangle {
    x, y := getFrameSourcePosition(sprite)
    return rl.Rectangle{
        x, y,
        spriteSize.x, spriteSize.y,
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