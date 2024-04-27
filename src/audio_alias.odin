package main

import "core:fmt"
import "core:math"
import "core:strings"

import rl "vendor:raylib"

maxAliases :: 20

SoundAlias :: struct {
    active: bool,

    alias: rl.Sound,
    generation: int,

    dynamicControl: DynamicAudioControl
}

init_SoundAlias :: proc(sound: ^rl.Sound, generation: ^int) -> SoundAlias {
    generation^ += 1
    return {
        true,
        rl.LoadSoundAlias(sound^),
        generation^,
        init_DynamicAudioControl(),
    }
}

destroy_SoundAlias :: proc(using soundAlias: ^SoundAlias, tag: string,  log: ^OutLog) {
    rl.UnloadSoundAlias(alias)
    writeAllocFreeToLog(log, tag)
    active = false
}

createNewSoundAlias :: proc(using handler: ^AudioHandler, tag: string, log: ^OutLog) -> string {

    tag := tag

    tagBuilder := strings.builder_make()

    // if the sound being referenced does not exist, then log an error
    if !rl.IsSoundReady(masterSounds[tag]) {
        // this will cause the new sound alias to reference the exception sound that is pre-loaded
        tag = getStateSoundExceptionTag()

        writeToLog(log, fmt.tprintf("ERROR - Tried referencing sound data from invalid tag '%s'", tag))
    }

    alias := init_SoundAlias(&masterSounds[tag], &generationCounter)

    fmt.sbprintf(&tagBuilder, "%s%d", tag, generationCounter)
    newTag := strings.to_string(tagBuilder)

    soundAliases[newTag] = alias

    rl.PlaySound(masterSounds[tag])

    return newTag
}