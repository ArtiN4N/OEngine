package main

import "core:fmt"
import "core:math"
import "core:strings"

import rl "vendor:raylib"

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
    
    soundAliases: map[string]SoundAlias,
    generationCounter: int,

    masterMusic: map[string]rl.Music,

    currentMusic: ^rl.Music,
    dynamicMusicControl: DynamicAudioControl
}

init_AudioHandler :: proc() -> AudioHandler {
    rl.InitAudioDevice()
    rl.SetMasterVolume(1.0)

    writeAllocToLog(varname = "audioHandler.masterSounds")
    writeAllocToLog(varname = "spriteHandler.soundAliases")
    writeAllocToLog(varname = "spriteHandler.masterMusic")

    return {
        make(map[string]rl.Sound),
        make(map[string]SoundAlias),
        0,
        make(map[string]rl.Music),
        nil,
        init_DynamicAudioControl(),
    }
}

destroy_AudioHandler :: proc(using handler: ^AudioHandler) {
    for tag, &alias in soundAliases {
        if alias.active do destroy_SoundAlias(&alias, tag)
    }
    delete(soundAliases)
    writeAllocFreeToLog(varname = "spriteHandler.soundAliases")

    for tag, sound in masterSounds {
        rl.UnloadSound(sound)
        writeDataFreeToLog(tag)
    }
    delete(masterSounds)
    writeAllocFreeToLog(varname = "spriteHandler.masterSounds")

    for tag, music in masterMusic {
        rl.UnloadMusicStream(music)
        writeDataFreeToLog(tag)
    }
    delete(masterMusic)
    writeAllocFreeToLog(varname = "spriteHandler.masterMusic")

    rl.CloseAudioDevice()
}

setAudioHandlerMusic :: proc(using handler: ^AudioHandler, tag: string, volume: f32 = 0.5) {
    if currentMusic != nil {
        // Since we're swapping tracks, we should stop the current one first
        rl.StopMusicStream(currentMusic^)
    }
    currentMusic = &masterMusic[tag]
    dynamicMusicControl = init_DynamicAudioControl()

    rl.SetMusicVolume(currentMusic^, volume)
}

playAudioHandlerMusic :: proc(using handler: ^AudioHandler) {
    if currentMusic == nil || !rl.IsMusicReady(currentMusic^) do return

    if !rl.IsMusicStreamPlaying(currentMusic^) do rl.PlayMusicStream(currentMusic^)
        
    else do rl.ResumeMusicStream(currentMusic^)
}

update_AudioHandler :: proc(using handler: ^AudioHandler, dt: f32) {
    for tag, &alias in soundAliases {
        if alias.active && alias.dynamicControl.active do updateDynamicAlias(&alias)
    }

    if currentMusic == nil do return

    if rl.IsMusicStreamPlaying(currentMusic^) {
        if dynamicMusicControl.active do updateDynamicMusic(handler, dt)

        // this is needed to make music actually play
        rl.UpdateMusicStream(currentMusic^)
    }
}