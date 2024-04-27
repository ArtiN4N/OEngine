package main

import "core:fmt"
import "core:math"
import "core:strings"

import rl "vendor:raylib"


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

addDynamicControlToAlias :: proc(
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

addDynamicControlToMusic :: proc(
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