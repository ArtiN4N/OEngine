package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

SpriteHandler :: struct {
    masterSprites: map[string]rl.Texture2D,
    spriteAliases: map[string]Sprite,

    generationCounter: int,
}

init_SpriteHandler :: proc() -> SpriteHandler {
    return {
        make(map[string]rl.Texture2D),
        make(map[string]Sprite),
        0,
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

createNewSpriteAlias :: proc(
    using handler: ^SpriteHandler, 
    spriteSize: rl.Vector2,
    textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2,
    tag: string, log: ^OutLog
) -> string {

    tagBuilder := strings.builder_make()

    if !rl.IsTextureReady(masterSprites[tag]) {
        fmt.sbprintf(&tagBuilder, "failure")
        failTag := strings.to_string(tagBuilder)

        return failTag
    }

    alias := init_Sprite(spriteSize, &masterSprites[tag], textureSourceOffset, textureDestOffset, tag, log)

    fmt.sbprintf(&tagBuilder, "%s%d", tag, generationCounter)
    generationCounter += 1

    newTag := strings.to_string(tagBuilder)

    spriteAliases[newTag] = alias

    return newTag
}

draw_SpriteHandler :: proc(using handler: SpriteHandler) {
    for tag, sprite in spriteAliases {
        draw_Sprite(sprite, 0.0)
    }
}