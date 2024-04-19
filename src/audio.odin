package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

maxAliases :: 20

DynamicAliasControl :: struct {
    // Plays in left or right ear depending on orientation from target
    locational: bool,
    // Is louder or quieter depending on distance from target
    dynamical: bool,

    source: ^rl.Vector2,
    target: ^rl.Vector2
}

SoundAlias :: struct {
    alias: rl.Sound,
    generation: int,

    active: bool,
    dynamicControl: Maybe(DynamicAliasControl)
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

    masterMusic: map[string]rl.Music
}

init_AudioHandler :: proc() -> AudioHandler {
    return {
        make(map[string]rl.Sound),
        make(map[string]SoundAlias),
        0,
        make(map[string]rl.Music)
    }
}

cleanUpAudioHandler :: proc(using handler: ^AudioHandler) {
    for tag, &alias in playingSoundAliasBuffer {
        if alias.active {
            cleanUpSoundAlias(&alias)
        }
    }
    delete(playingSoundAliasBuffer)

    for tag, sound in masterSounds {
        rl.UnloadSound(sound)
    }
    delete(masterSounds)

    for tag, music in masterMusic {
        rl.UnloadMusicStream(music)
    }
    delete(masterMusic)
}

createNewSoundAlias :: proc(using handler: ^AudioHandler, tag: string) -> string {
    alias := init_SoundAlias(&masterSounds[tag], &generationCounter)

    tagBuilder := strings.builder_make()
    fmt.sbprintf(&tagBuilder, "%s%d", tag, generationCounter)
    newTag := strings.to_string(tagBuilder)

    playingSoundAliasBuffer[newTag] = alias
    return newTag
}
