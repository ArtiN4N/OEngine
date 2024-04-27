package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

SpriteHandler :: struct {
    masterSprites: map[string]rl.Texture2D,
    spriteAliases: map[string]Sprite,
}

init_SpriteHandler :: proc() -> SpriteHandler {
    return {
        make(map[string]rl.Texture2D),
        make(map[string]Sprite),
    }
}

destroy_SpriteHandler :: proc(using handler: ^SpriteHandler, log: ^OutLog) {
    for tag, &sprite in spriteAliases {
        destroy_Sprite(&sprite, tag, log)
    }
    delete(spriteAliases)

    for tag, texture in masterSprites {
        writeDataFreeToLog(log, tag)
        rl.UnloadTexture(texture)
    }
    delete(masterSprites)
}

update_SpriteHandler :: proc(using handler: ^SpriteHandler, dt: f32) {
    for tag, &sprite in spriteAliases {
        update_AnimationControl(&sprite.animationControl, dt)
    }
} 