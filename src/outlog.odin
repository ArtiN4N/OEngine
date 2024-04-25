package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

OutLog :: struct {
    logBuilder: strings.Builder,
    loads: int,
    frees: int,
    timeElapsed: f32,
}

init_OutLog :: proc() -> OutLog {
    curTime := time.now()

    builder := strings.builder_make()

    hour, min, sec := time.clock_from_time(curTime)

    fmt.sbprintf(
        &builder, 
        "----------INIT FRAME----------\nExecuted at time %4d:%2d:%2d - %2d:%2d:%2d\n", 
        time.date(curTime), (hour - 7) % 24, min, sec
    )

    initText: [^]u8
    rl.SaveFileText("log.txt", initText)

    return {
        builder,
        0, 0,
        0.0
    }
}

stepOutLog :: proc(using out: ^OutLog, dt: f32) {
    timeElapsed += dt
}

writeToLog :: proc(using out: ^OutLog, data: string) {
    fmt.sbprintf(&logBuilder, "%s -> logged at time %.2f\n", data, timeElapsed)
}

writeTextureLoadToLog :: proc(using out: ^OutLog, tag: string, success: bool) {
    if !success {
        writeToLog(out, fmt.tprintf("ERROR - Failed to load texture data from '%s'", tag))
        return
    }
    writeToLog(out, fmt.tprintf("Loaded texture data from tag '%s'", tag))
    loads += 1
}

writeAudioLoadToLog :: proc(using out: ^OutLog, tag: string, success: bool) {
    if !success {
        writeToLog(out, fmt.tprintf("ERROR - Failed to load audio data from '%s'", tag))
        return
    }
    writeToLog(out, fmt.tprintf("Loaded audio data from tag '%s'", tag))
    loads += 1
}

writeFileLoadToLog :: proc(using out: ^OutLog, tag: string) {
    writeToLog(out, fmt.tprintf("Loaded file data from tag '%s'", tag))
    loads += 1
}

writeAllocToLog :: proc(using out: ^OutLog, varname: string) {
    writeToLog(out, fmt.tprintf("Alloc'd memory to variable '%s'", varname))
    loads += 1
}

writeDataFreeToLog :: proc(using out: ^OutLog, tag: string) {
    writeToLog(out, fmt.tprintf("Freed data from tag '%s'", tag))
    frees += 1
}

writeAllocFreeToLog :: proc(using out: ^OutLog, varname: string) {
    writeToLog(out, fmt.tprintf("Freed memory from variable '%s'", varname))
    frees += 1
}

writeFrameHeader :: proc(using out: ^OutLog, title: string) {
    fmt.sbprintf(&logBuilder, "\n----------%s FRAME----------\n", title)
}

writeLogToFile :: proc(using out: ^OutLog) {
    fmt.sbprintf(
        &logBuilder, 
        "\n----------EXIT FRAME----------\nTOTAL LOADS: %3d\nTOTAL FREES: %3d\nLOADS == FREES: %t", 
        loads, frees, loads == frees
    )

    rl.SaveFileText("log.txt", raw_data(strings.to_string(logBuilder)))
}
