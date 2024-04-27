package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"


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
    tag: string,
}

// Function to create sprite animations
init_SpriteAnimation :: proc(
    animationSourceOffset: rl.Vector2, 
    frames: int, fps, framePeriod: int, linger: f32, 
    tag: string
) -> SpriteAnimation {
    return {
        animationSourceOffset, 
        frames, fps, framePeriod, linger, 
        tag,
    }
}


AnimationControl :: struct {
    active: bool,
    
    animations: map[string]SpriteAnimation,
    currentAnimation: ^SpriteAnimation,

    currentFrame: int,
    currentTime: f32,
}

init_AnimationControl :: proc(tag: string, log: ^OutLog) -> AnimationControl {
    writeAllocToLog(log, tag)

    return {
        false,
        make(map[string]SpriteAnimation), nil,
        0, 0.0
    }
}

destroy_AnimationControl :: proc(using control: ^AnimationControl, tag: string, log: ^OutLog) {
    writeAllocFreeToLog(log, tag)
    delete(animations)
}

addAnimationToSprite :: proc(
    using sprite: ^Sprite, 
    animationSourceOffset: rl.Vector2, frames, fps, framePeriod: int, linger: f32,
    tag: string
) {
    using sprite.animationControl

    animations[tag] = init_SpriteAnimation(animationSourceOffset, frames, fps, framePeriod, linger, tag)
    currentAnimation = &animations[tag]

    // first added animation should activate the andimation controller
    if !active do active = true
}


ChangeSpriteAnimation :: proc(using sprite: ^Sprite, tag: string) {
    using sprite.animationControl

    // change the current animation, and reset the frame number and counter
    currentAnimation = &animations[tag]
    currentFrame = 0
    currentTime = 0.0
}

update_AnimationControl :: proc(using control: ^AnimationControl, dt: f32) {
    if !active do return

    currentTime += dt

    // If we're on the last frame, override the frame per second calculation in favor of a linger frame
    // Each animation has a linger value that specifies how long the last frame will linger for.
    if currentFrame == currentAnimation.frames - 1 {
        // A value of -1.0 (less than 0) will cause the last frame to linger forever
        if currentAnimation.linger < 0.0 do return
            
        // Otherwise, count down until the linger is over, and reset the animtion
        else if currentTime >= currentAnimation.linger  {
            currentFrame = 0
            currentTime = 0.0
            return
        }
    }

    // one over frames per second is seconds per frame, which we use to count to when a frame should be updated
    if currentTime >= 1.0 / auto_cast currentAnimation.fps {
        currentTime = 0.0
        currentFrame += 1

        // cycle from last frame to first frame (automatic looping)
        // you can use a linger value of -1 to disable looping
        if currentFrame >= currentAnimation.frames do currentFrame = 0
    }
}
