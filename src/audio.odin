package main

import "core:fmt"
import "core:math"
import "core:strings"

import rl "vendor:raylib"

maxAliases :: 20

DynamicAudioControl :: struct {
    active: bool,

    defaultVolume: f32,
    // Plays in left or right ear depending on orientation from source
    locational: bool,
    // Is louder or quieter depending on distance from source
    dynamical: bool,

    source: ^rl.Vector2,
    follow: ^rl.Vector2,

    // dynamicScale determines how the audio changes in volume as source differs from follow.
    // For each multiple of scale.x that follow is away from source.x, the audio decreases by .01
    // Works the same for the y axis.
    // Works the same for locationalScale
    locationalScale: rl.Vector2,
    dynamicScale: rl.Vector2,

    // For slowing down / speeding up audio
    pitch: f32,
    realPitch: f32,
    targetPitch: f32,
    pitchSpeed: f32,
}

init_DynamicAudioControl :: proc() -> DynamicAudioControl {
    return {
        false, 0,
        false, false,
        nil, nil,
        {0, 0}, {0, 0},
        0, 0, 0, 0,
    }
}

attachDynamicAudioControlToAlias :: proc(
    using soundAlias: ^SoundAlias, 
    defaultVol: f32, 
    loc, dyn: bool, 
    src, folw: ^rl.Vector2, 
    locScale, dynScale: rl.Vector2
) {
    dynamicControl = {
        true, defaultVol,
        loc, dyn,
        src, folw,
        locScale, dynScale,
        1.0, 1.0, 1.0, 0.1,
    }
}

SoundAlias :: struct {
    alias: rl.Sound,
    generation: int,

    active: bool,
    dynamicControl: DynamicAudioControl
}

init_SoundAlias :: proc(sound: ^rl.Sound, generation: ^int) -> SoundAlias {
    generation^ += 1
    return {
        rl.LoadSoundAlias(sound^),
        generation^,
        true,
        init_DynamicAudioControl(),
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
    dynamicMusicControl: DynamicAudioControl
}

init_AudioHandler :: proc() -> AudioHandler {
    rl.InitAudioDevice()
    rl.SetMasterVolume(1.0)
    return {
        make(map[string]rl.Sound),
        make(map[string]SoundAlias),
        0,
        make(map[string]rl.Music),
        nil,
        init_DynamicAudioControl(),
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

setAudioHandlerMusic :: proc(using handler: ^AudioHandler, tag: string, volume: f32) {
    if currentMusic != nil {
        rl.StopMusicStream(currentMusic^)
    }
    currentMusic = &masterMusic[tag]
    dynamicMusicControl = init_DynamicAudioControl()

    rl.SetMusicVolume(currentMusic^, volume)
}

attachDynamicAudioControlToMusic :: proc(
    using handler: ^AudioHandler, 
    defaultVol: f32, 
    loc, dyn: bool, 
    src, folw: ^rl.Vector2, 
    locScale, dynScale: rl.Vector2
) {
    dynamicMusicControl = {
        true, defaultVol,
        loc, dyn,
        src, folw,
        locScale, dynScale,
        1.0, 1.0, 1.0, 0.1,
    }
}

playAudioHandlerMusic :: proc(using handler: ^AudioHandler) {
    if currentMusic == nil || !rl.IsMusicReady(currentMusic^) do return

    if !rl.IsMusicStreamPlaying(currentMusic^) do rl.PlayMusicStream(currentMusic^)
        
    else do rl.ResumeMusicStream(currentMusic^)
}

updateAudioHandler :: proc(using handler: ^AudioHandler, dt: f32) {
    for tag, &alias in playingSoundAliasBuffer {
        if alias.active && alias.dynamicControl.active do updateDynamicAlias(&alias)
    }

    if currentMusic == nil do return

    if rl.IsMusicStreamPlaying(currentMusic^) {
        if dynamicMusicControl.active do updateDynamicMusic(handler, dt)

        rl.UpdateMusicStream(currentMusic^)
    }
}

setDyanmicPitchTargetWithSpeed :: proc(using dynamicControl: ^DynamicAudioControl, target, speed: f32) {
    targetPitch = target
    pitchSpeed = speed
}

updateDynamicMusic :: proc(using handler: ^AudioHandler, dt: f32) {
    if !dynamicMusicControl.active do return

    if dynamicMusicControl.locational {
        if dynamicMusicControl.follow == nil || dynamicMusicControl.source == nil do return

        xDist := dynamicMusicControl.source^.x - dynamicMusicControl.follow^.x
        xPanScale := xDist / dynamicMusicControl.dynamicScale.x 
        if xPanScale > 5.0 do xPanScale = 5.0
        if xPanScale < -5.0 do xPanScale = -5.0

        // Changes audio pan by units of 0.1
        rl.SetMusicPan(currentMusic^, 0.5 + (xPanScale * 0.1))
    }

    if dynamicMusicControl.dynamical {
        if dynamicMusicControl.follow == nil || dynamicMusicControl.source == nil do return

        xDist := abs(dynamicMusicControl.source^.x - dynamicMusicControl.follow^.x)
        xVolScale := xDist / dynamicMusicControl.dynamicScale.x 
        if xVolScale > 10.0 do xVolScale = 10.0

        // Changes audio volume by units of 0.1
        rl.SetMusicVolume(currentMusic^, dynamicMusicControl.defaultVolume - (xVolScale * 0.1))
    }

    if dynamicMusicControl.realPitch != dynamicMusicControl.targetPitch {
        direction := math.sign_f32(dynamicMusicControl.targetPitch - dynamicMusicControl.realPitch)

        // Real pitch is clamped to the second decimal to make it sound better
        dynamicMusicControl.pitch += direction * dynamicMusicControl.pitchSpeed * dt
        dynamicMusicControl.realPitch = math.round(dynamicMusicControl.pitch * 100) / 100

        rl.SetMusicPitch(currentMusic^, dynamicMusicControl.realPitch)
    }
}

updateDynamicAlias :: proc(using soundAlias: ^SoundAlias) {
    if !dynamicControl.active do return
}