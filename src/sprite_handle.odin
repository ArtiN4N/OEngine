package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

SpriteHandler :: struct {
    // masterSprites stores all the texture data used in the game
    // when a texture is to be drawn onto the screen, an "alias" to the
    // original texture is created by way of a sprite
    // These sprite aliases are also all stored in this struct
    masterSprites: map[string]rl.Texture2D,
    spriteAliases: map[string]Sprite,
    
    // generationCounter is used to identify the aliases in the system
    generationCounter: int,
}

init_SpriteHandler :: proc() -> SpriteHandler {
    writeAllocToLog(varname = "spriteHandler.masterSprites")
    writeAllocToLog(varname = "spriteHandler.spriteAliases")

    return {
        make(map[string]rl.Texture2D),
        make(map[string]Sprite),
        0,
    }
}

destroy_SpriteHandler :: proc(using handler: ^SpriteHandler) {
    for tag, &sprite in spriteAliases do destroy_Sprite(&sprite, tag)

    delete(spriteAliases)
    writeAllocFreeToLog(varname = "spriteHandler.spriteAliases")

    for tag, texture in masterSprites {
        rl.UnloadTexture(texture)
        writeDataFreeToLog(tag)
    }
    delete(masterSprites)
    writeAllocFreeToLog(varname = "spriteHandler.masterSprites")
}

update_SpriteHandler :: proc(using handler: ^SpriteHandler, dt: f32) {
    for tag, &sprite in spriteAliases do update_AnimationControl(&sprite.animationControl, dt)
}

// A sprite alias is created by referencing an existing texture by tag
// spriteSize is the size of the texture to be drawn onto the screen
// textureSourceOffset is the position in the referenced texture that the sprite begins
// textureDestOffset is the position on the screen that the sprite is shifted to
// tag is used to identify the original texture data being referenced
createNewSpriteAlias :: proc(
    using handler: ^SpriteHandler,
    tag: string,
    spriteSize: rl.Vector2,
    textureSourceOffset: rl.Vector2, textureDestOffset: rl.Vector2,
) -> string {

    tag := tag

    tagBuilder := strings.builder_make()

    // if the texture being referenced does not exist, then log an error
    if !rl.IsTextureReady(masterSprites[tag]) {
        // this will cause the new sprite alias to reference the exception texture that is pre-loaded
        tag = getStateTextureExceptionTag()

        writeToLog(fmt.caprintf("ERROR - Tried referencing texture data from invalid tag '%s'", tag))
    }

    alias := init_Sprite(tag, spriteSize, &masterSprites[tag], textureSourceOffset, textureDestOffset)

    fmt.sbprintf(&tagBuilder, "%s%d", tag, generationCounter)
    generationCounter += 1

    newTag := strings.to_string(tagBuilder)

    spriteAliases[newTag] = alias

    return newTag
}

draw_SpriteHandler :: proc(using handler: SpriteHandler) {
    for tag, sprite in spriteAliases do draw_Sprite(sprite, 0.0)
}