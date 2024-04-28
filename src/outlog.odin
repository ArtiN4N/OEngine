package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

loads: i32 = 0
frees: i32 = 0
time: f32 = 0.0

writeToLog :: proc(data: cstring) {
    rl.SaveFileText("log.txt", data)
}

stepLog :: proc(dt: f32) {
    time += dt
}

writeFrameHeader :: proc(title: string) {
    writeToLog(fmt.caprintf("\n----------%s FRAME----------\n", title))
}

writeEnterFrame :: proc() {
    curTime := time.now()
    hour, min, sec := time.clock_from_time(curTime)

    writeToLog(fmt.caprintf(
        "----------INIT FRAME----------\nExecuted at time %4d:%2d:%2d - %2d:%2d:%2d\n", 
        time.date(curTime), (hour - 7) % 24, min, sec
    ))
}

writeExitFrame :: proc() {
    writeToLog(fmt.caprintf(
        "\n----------EXIT FRAME----------\nTOTAL LOADS: %3d\nTOTAL FREES: %3d\nLOADS == FREES: %t",
        loads, frees, loads == frees
    ))
}

writeTextureLoadToLog :: proc(using out: ^OutLog, tag: string, success: bool) {
    if !success {
        writeToLog(fmt.caprintf("ERROR - Failed to load texture data from '%s'", tag))
        return
    }
    writeToLog(fmt.caprintf("Loaded texture data from tag '%s'", tag))
    loads += 1
}

writeAudioLoadToLog :: proc(tag: string, success: bool) {
    if !success {
        writeToLog(fmt.caprintf("ERROR - Failed to load audio data from '%s'", tag))
        return
    }
    writeToLog(out, fmt.caprintf("Loaded audio data from tag '%s'", tag))
    loads += 1
}

writeFileLoadToLog :: proc(tag: string) {
    writeToLog(out, fmt.caprintf("Loaded file data from tag '%s'", tag))
    loads += 1
}

writeAllocToLog :: proc(varname: string) {
    writeToLog(fmt.caprintf("Alloc'd memory to variable '%s'", varname))
    loads += 1
}

writeDataFreeToLog :: proc(tag: string) {
    writeToLog(fmt.caprintf("Freed data from tag '%s'", tag))
    frees += 1
}

writeAllocFreeToLog :: proc(varname: string) {
    writeToLog(fmt.caprintf("Freed memory from variable '%s'", varname))
    frees += 1
}
