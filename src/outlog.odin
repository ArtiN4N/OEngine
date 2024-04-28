package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

loads: i32 = 0
frees: i32 = 0
elapsed: f64 = 0.0
builder := strings.builder_make()

finalizeLog :: proc() {
    rl.SaveFileText("log.txt", raw_data(strings.to_string(builder)))
}

writeToLog :: proc(data: cstring) {
    stepLog()
    fmt.sbprintf(&builder, "%s -- logged at time %.2f\n", data, elapsed)
}

stepLog :: proc() {
    elapsed = rl.GetTime()
}

writeFrameHeader :: proc(title: string) {
    fmt.sbprintf(&builder, "\n----------%s FRAME----------\n", title)
}

writeEnterFrame :: proc() {
    curTime := time.now()
    hour, min, sec := time.clock_from_time(curTime)

    fmt.sbprintf(
        &builder, 
        "----------INIT FRAME----------\nExecuted at time %4d:%2d:%2d - %2d:%2d:%2d\n", 
        time.date(curTime), (hour + 24 - 7) % 24, min, sec
    )
}

writeExitFrame :: proc() {
    fmt.sbprintf(
        &builder, 
        "\n----------EXIT FRAME----------\nTOTAL LOADS: %3d\nTOTAL FREES: %3d\nLOADS == FREES: %t",
        loads, frees, loads == frees
    )
}

writeTextureLoadToLog :: proc(tag: string, success: bool) {
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
    writeToLog(fmt.caprintf("Loaded audio data from tag '%s'", tag))
    loads += 1
}

writeFileLoadToLog :: proc(tag: string) {
    writeToLog(fmt.caprintf("Loaded file data from tag '%s'", tag))
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
