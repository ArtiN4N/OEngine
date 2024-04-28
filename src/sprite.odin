package main

import "core:strings"

import rl "vendor:raylib"


Sprite :: struct {
    animationControl: AnimationControl,

    spriteSize: rl.Vector2,

    texture: ^rl.Texture2D,
    textureSourceOffset: rl.Vector2,
    textureDestOffset: rl.Vector2
}

init_Sprite :: proc(
    log: ^OutLog,
    tag: string, 
    spriteSize: rl.Vector2,
    texture: ^rl.Texture2D, 
    textureSourceOffset: rl.Vector2 = {0, 0}, textureDestOffset: rl.Vector2 = {0, 0},
) -> Sprite {
    return {
        init_AnimationControl(tag, log),
        spriteSize,
        texture, textureSourceOffset, textureDestOffset,
    }
}

destroy_Sprite :: proc(using sprite: ^Sprite, log: ^OutLog, tag: string) {
    if animationControl.active do destroy_AnimationControl(&animationControl, tag, log)
}

getFrameSourcePosition :: proc(using sprite: Sprite) -> (f32, f32) {
    // The source position is where in the parent's sprite sheet the current frame to draw resides
    x := textureSourceOffset.x
    y := textureSourceOffset.y
    
    // If the frame in question is apart of an animation, the source frame gets pushed to the right for every frame.
    // After a number of frames specified by the animation's frame period, the source position is snapped back to the
    // left, and pushed down.
    using animationControl
    if active && currentAnimation != nil {
        x += currentAnimation.animationSourceOffset.x
        y += currentAnimation.animationSourceOffset.y
        
        x += spriteSize.x * auto_cast (currentFrame % currentAnimation.framePeriod)
        y += spriteSize.y * auto_cast (currentFrame / currentAnimation.framePeriod)
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

draw_Sprite :: proc(
    using sprite: Sprite, 
    position: rl.Vector2 = {0, 0}, size: rl.Vector2 = {100, 100}, 
    rotation: f32 = 0.0,
) {
    rl.DrawTexturePro(
        texture^,
        getSpriteSourceRec(sprite),
        // temporary - should be drawing at position/size provided by user/code
        rl.Rectangle{position.x, position.y, size.x, size.y}, 
        textureDestOffset,
        rotation,
        rl.RAYWHITE
    )
}
