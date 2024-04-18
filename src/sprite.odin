package main

import "core:strings"

import rl "vendor:raylib"


// Sprite animation struct and init function
//-----------------------------------------------------------------------------------------------
SpriteAnimation :: struct {
    // Where the first frame of the current animation is located in its parent's spritesheet
    animationSourceOffset: rl.Vector2,
    frames: int,
    fps: int,
    // Describes how many frames should be read from the spritesheet from a specific row until the row is pushed downwards.
    // If framePeriod == frames, then all frames of a sprite exist on the same spritesheet row
    framePeriod: int,
    // Describes how long the last frame lingers for. Set to -1.0 for forever.
    linger: f32,
    // Identifying tag used to set current animation
    tag: string
}

// Function to create sprite animations
init_SpriteAnimation :: proc(animationSourceOffset: rl.Vector2, frames: int, fps, framePeriod: int, linger: f32, tag: string) -> SpriteAnimation {
    return {
        animationSourceOffset, frames, fps, framePeriod, linger, tag
    }
}
//-----------------------------------------------------------------------------------------------



// Animation controller functions
//-----------------------------------------------------------------------------------------------
SpriteAnimationController :: struct {
    animations: map[string]SpriteAnimation,
    currentAnimation: ^SpriteAnimation,

    curFrame: int,
    curTime: f32,
}

init_SpriteAnimationController :: proc() -> SpriteAnimationController {
    return {
        make(map[string]SpriteAnimation), nil,
        0, 0.0
    }
}

free_SpriteAnimationController :: proc(using controller: ^SpriteAnimationController, log: ^OutLog) {
    writeAllocFreeToLog(log, "SpriteAnimationController.animations")
    delete(animations)
}

addAnimationToSpriteController :: proc(
    using controller: ^SpriteAnimationController, 
    animationSourceOffset: rl.Vector2, frames, fps, framePeriod: int, linger: f32,
    tag: string
) {
    animations[tag] = init_SpriteAnimation(animationSourceOffset, frames, fps, framePeriod, linger, tag)
    currentAnimation = &animations[tag]
}
//-----------------------------------------------------------------------------------------------



// Animation controller update functions
//-----------------------------------------------------------------------------------------------
ChangeSpriteAnimation :: proc(using controller: ^SpriteAnimationController, tag: string) {
    currentAnimation = &animations[tag]
    curFrame = 0
    curTime = 0.0
}

SpriteAnimationUpdate :: proc(using controller: ^SpriteAnimationController, dt: f32, log: ^OutLog) {
    if currentAnimation == nil {
        writeToLog(log, "ERROR - tried to update a sprite without an animation")
        return
    }

    curTime += dt

    // If we're on the last frame, override the frame per second calculation in favor of a linger frame
    // Each animation has a linger value that specifies how long the last frame will linger for.
    if curFrame == currentAnimation.frames - 1 {
        // A value of -1.0 (less than 0) will cause the last frame to linger forever
        if currentAnimation.linger < 0.0 {
            return
        // Otherwise, count down until the linger is over, and reset the animtion
        } else if currentAnimation.linger > 0.0 {
            if curTime >= currentAnimation.linger {
                curFrame = 0
                curTime = 0.0
            }

            return
        }
    }

    // one over frames per second is seconds per frame, which we use to count to when a frame should be updated
    if curTime >= 1.0 / auto_cast currentAnimation.fps {
        curTime = 0.0
        curFrame += 1

        if curFrame >= currentAnimation.frames {
            curFrame = 0
        }
    }
}
//-----------------------------------------------------------------------------------------------



// Sprite init functions
//-----------------------------------------------------------------------------------------------
Sprite :: struct {
    animated: bool,
    animationController: SpriteAnimationController,

    spriteSize: rl.Vector2,

    texture: ^rl.Texture2D,
    textureSourceOffset: rl.Vector2,
    textureDestOffset: rl.Vector2
}

init_Sprite :: proc(
    spriteSize: rl.Vector2,
    texture: ^rl.Texture2D, textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2
) -> Sprite {
    return {
        false, init_SpriteAnimationController(),
        spriteSize,
        texture, textureSourceOffset, textureDestOffset,
    }
}

attachSpriteAnimationController :: proc(using sprite: ^Sprite, log: ^OutLog) {
    animated = true;
    animationController = init_SpriteAnimationController()
    writeAllocToLog(log, "SpriteAnimationController.animations")
}
//-----------------------------------------------------------------------------------------------



// Sprite drawing and util functions
//-----------------------------------------------------------------------------------------------
getFrameSourcePosition :: proc(using sprite: Sprite) -> (f32, f32) {
    // The source position is where in the parent's sprite sheet the current frame to draw resides
    x := textureSourceOffset.x
    y := textureSourceOffset.y
    
    // If the frame in question is apart of an animation, the source frame gets pushed to the right for every frame.
    // After a number of frames specified by the animation's frame period, the source position is snapped back to the
    // left, and pushed down.
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

drawSprite :: proc(using sprite: Sprite, rotation: f32) {
    rl.DrawTexturePro(
        texture^,
        getSpriteSourceRec(sprite), 
        rl.Rectangle{100, 100, 256, 256}, 
        textureDestOffset,
        rotation,
        rl.RAYWHITE
    )
}
//-----------------------------------------------------------------------------------------------
