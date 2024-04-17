package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

OutLog :: struct {
    logBuilder: strings.Builder,
    loads: int,
    frees: int,
}

init_OutLog :: proc() -> OutLog {
    curTime := time.now()

    builder := strings.builder_make()

    hour, min, sec := time.clock_from_time(curTime)

    fmt.sbprintf(
        &builder, 
        "----------INIT FRAME----------\nExecuted at time %4d:%2d:%2d - %2d:%2d:%2d\n------------------------------\n\n", 
        time.date(curTime), (hour - 7) % 24, min, sec
    )

    initText: [^]u8
    rl.SaveFileText("log.txt", initText)

    return {
        builder,
        0, 0
    }
}

writeToLog :: proc(using out: ^OutLog, data: string) {
    strings.write_string(&logBuilder, data)
}

writeTextureLoadToLog :: proc(using out: ^OutLog, filename: string, success: bool) {
    if !success {
        fmt.sbprintf(&logBuilder, "ERROR - Failed to load texture data from '%s'\n", filename)
        return
    }
    fmt.sbprintf(&logBuilder, "Loaded texture data from '%s'\n", filename)
    loads += 1
}

writeAudioLoadToLog :: proc(using out: ^OutLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Loaded audio data from '%s'\n", filename)
    loads += 1
}

writeFileLoadToLog :: proc(using out: ^OutLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Loaded file data from '%s'\n", filename)
    loads += 1
}

writeAllocToLog :: proc(using out: ^OutLog, varname: string) {
    fmt.sbprintf(&logBuilder, "Alloc'd memory to variable '%s'\n", varname)
    loads += 1
}

writeDataFreeToLog :: proc(using out: ^OutLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Freed data from '%s'\n", filename)
    frees += 1
}

writeAllocFreeToLog :: proc(using out: ^OutLog, varname: string) {
    fmt.sbprintf(&logBuilder, "Freed memory from variable '%s'\n", varname)
    frees += 1
}

writeLogToFile :: proc(using out: ^OutLog) {
    fmt.sbprintf(
        &logBuilder, 
        "\n----------EXIT FRAME----------\nTOTAL LOADS: %3d\nTOTAL FREES: %3d\nLOADS == FREES: %t\n------------------------------", 
        loads, frees, loads == frees
    )

    rl.SaveFileText("log.txt", raw_data(strings.to_string(logBuilder)))
}
