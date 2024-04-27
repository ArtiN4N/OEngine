package main

import "core:strings"

import rl "vendor:raylib"

// Sprite init functions
//-----------------------------------------------------------------------------------------------
Sprite :: struct {
    animationControl: AnimationControl,

    spriteSize: rl.Vector2,

    texture: ^rl.Texture2D,
    textureSourceOffset: rl.Vector2,
    textureDestOffset: rl.Vector2
}

init_Sprite :: proc(
    spriteSize: rl.Vector2,
    texture: ^rl.Texture2D, textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2,
    tag: string, log: ^OutLog,
) -> Sprite {
    return {
        init_AnimationControl(tag, log),
        spriteSize,
        texture, textureSourceOffset, textureDestOffset,
    }
}

destroy_Sprite :: proc(using sprite: ^Sprite, tag: string, log: ^OutLog) {
    if animationControl.active {
        destroy_AnimationControl(&animationControl, tag, log)
    }
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
    using animationControl
    if active && currentAnimation != nil {
        x += currentAnimation.animationSourceOffset.x
        y += currentAnimation.animationSourceOffset.y
        
        x += spriteSize.x * auto_cast (curFrame % currentAnimation.framePeriod)
        y += spriteSize.y * auto_cast (curFrame / currentAnimation.framePeriod)
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
