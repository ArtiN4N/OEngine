package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

maxAliases :: 20

DynamicAudioControl :: struct {
    // Plays in left or right ear depending on orientation from target
    locational: bool,
    // Is louder or quieter depending on distance from target
    dynamical: bool,

    source: ^rl.Vector2,
    target: ^rl.Vector2
}

init_DynamicAudioControl :: proc(loc, dyn: bool, src, trgt: ^rl.Vector2) -> DynamicAudioControl {
    return {
        loc,
        dyn,
        src,
        trgt,
    }
}

addDynamicControlToAlias :: proc(using soundAlias: ^SoundAlias, loc, dyn: bool, src, trgt: ^rl.Vector2) {
    dynamicControl = init_DynamicAudioControl(loc, dyn, src, trgt)
}

updateDynamicAlias :: proc(using soundAlias: ^SoundAlias) {
    if dynamicControl == nil do return
}

SoundAlias :: struct {
    alias: rl.Sound,
    generation: int,

    active: bool,
    dynamicControl: Maybe(DynamicAudioControl)
}

init_SoundAlias :: proc(sound: ^rl.Sound, generation: ^int) -> SoundAlias {
    generation^ += 1
    return {
        rl.LoadSoundAlias(sound^),
        generation^,
        true,
        nil,
    }
}

cleanUpSoundAlias :: proc(using soundAlias: ^SoundAlias) {
    rl.UnloadSoundAlias(alias)
    active = false
}

// The audio handler contains a master map of all sound effects

// The sound effects that are actually played are aliases. 
// Aliases don't own the original sound data, but can be played.
// A maximum of 20 (maxAliases) aliases can be playing at one time.
// When some area of the code wants to play a sound, it gives the audio
// handler a tag. It uses the tag to search up the orignal sound data.
// Then, it creates an alias from it, and adds it to the alias playing buffer.
// If a sound is queued while the playing buffer is full, the handler looks for
// a spot where an alias is no longer playing. If so, the alias is removed, and unloaded.
// Otherwise, the oldest alias is removed.

AudioHandler :: struct {
    masterSounds: map[string]rl.Sound,
    
    playingSoundAliasBuffer: map[string]SoundAlias,
    generationCounter: int,

    masterMusic: map[string]rl.Music,

    currentMusic: ^rl.Music,
    dynamicMusicControl: Maybe(DynamicAudioControl)
}

init_AudioHandler :: proc() -> AudioHandler {
    rl.InitAudioDevice()
    return {
        make(map[string]rl.Sound),
        make(map[string]SoundAlias),
        0,
        make(map[string]rl.Music),
        nil,
        nil
    }
}

cleanUpAudioHandler :: proc(using handler: ^AudioHandler, log: ^OutLog) {
    for tag, &alias in playingSoundAliasBuffer {
        if alias.active {
            cleanUpSoundAlias(&alias)
        }
    }
    delete(playingSoundAliasBuffer)

    for tag, sound in masterSounds {
        rl.UnloadSound(sound)
        writeDataFreeToLog(log, tag)
    }
    delete(masterSounds)

    for tag, music in masterMusic {
        rl.UnloadMusicStream(music)
        writeDataFreeToLog(log, tag)
    }
    delete(masterMusic)

    rl.CloseAudioDevice()
}

createNewSoundAlias :: proc(using handler: ^AudioHandler, tag: string) -> string {

    tagBuilder := strings.builder_make()

    if !rl.IsSoundReady(masterSounds[tag]) {
        fmt.sbprintf(&tagBuilder, "failure")
        failTag := strings.to_string(tagBuilder)

        return failTag
    }

    alias := init_SoundAlias(&masterSounds[tag], &generationCounter)

    fmt.sbprintf(&tagBuilder, "%s%d", tag, generationCounter)
    newTag := strings.to_string(tagBuilder)

    playingSoundAliasBuffer[newTag] = alias

    rl.PlaySound(masterSounds[tag])

    return newTag
}

setAudioHandlerMusic :: proc(using handler: ^AudioHandler, tag: string) {
    if currentMusic != nil {
        rl.StopMusicStream(currentMusic^)
    }
    currentMusic = &masterMusic[tag]
    dynamicMusicControl = nil
}

makeAudioHandlerMusicDynamic :: proc(using handler: ^AudioHandler, loc, dyn: bool, src, trgt: ^rl.Vector2) {
    dynamicMusicControl = init_DynamicAudioControl(loc, dyn, src, trgt)
}

playAudioHandlerMusic :: proc(using handler: ^AudioHandler) {
    if currentMusic == nil || !rl.IsMusicReady(currentMusic^) do return

    if !rl.IsMusicStreamPlaying(currentMusic^) do rl.PlayMusicStream(currentMusic^)
        
    else do rl.ResumeMusicStream(currentMusic^)
}

updateAudioHandler :: proc(using handler: ^AudioHandler) {
    for tag, &alias in playingSoundAliasBuffer {
        if alias.active && alias.dynamicControl != nil do updateDynamicAlias(&alias)
    }

    if rl.IsMusicStreamPlaying(currentMusic^) {
        if dynamicMusicControl != nil {

        }

        rl.UpdateMusicStream(currentMusic^)
    }
}