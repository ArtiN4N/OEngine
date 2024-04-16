package main

import "core:fmt"
import "core:time"
import "core:strings"

import rl "vendor:raylib"

outLog :: struct {
    logBuilder: strings.Builder,
    loads: int,
    frees: int,
}

init_outLog :: proc() -> outLog {
    curTime := time.now()

    builder := strings.builder_make()

    hour, min, sec := time.clock_from_time(curTime)

    fmt.sbprintf(&builder, "Executed at time %4d:%2d:%2d - %2d:%2d:%2d\n", time.date(curTime), (hour - 7) % 24, min, sec)

    return outLog {
        builder,
        0, 0
    }
}


writeToLog :: proc(using out: ^outLog, data: string) {
    strings.write_string(&logBuilder, data)
}

writeTextureLoadToLog :: proc(using out: ^outLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Loaded texture data from '%s'\n", filename)
}

writeAudioLoadToLog :: proc(using out: ^outLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Loaded audio data from '%s'\n", filename)
}

writeFileLoadToLog :: proc(using out: ^outLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Loaded file data from '%s'\n", filename)
}

writeDataFreeToLog :: proc(using  out: ^outLog, filename: string) {
    fmt.sbprintf(&logBuilder, "Freed data from '%s'\n", filename)
}

writeAllocToLog :: proc(using  out: ^outLog, varname: string) {
    fmt.sbprintf(&logBuilder, "Alloc'd memory to variable '%s'\n", varname)
}

writeAllocFreeToLog :: proc(using  out: ^outLog, varname: string) {
    fmt.sbprintf(&logBuilder, "Freed memory from variable '%s'\n", varname)
}

writeLogToFile :: proc(using out: ^outLog) {
    fmt.sbprintf(
        &logBuilder, 
        "\n----------EXIT FRAME----------\nTOTAL LOADS: %3d\nTOTAL FREES: %3d\nLOADS == FREES: %t\n------------------------------", 
        loads, frees, loads == frees
    )

    rl.SaveFileText("log.txt", raw_data(strings.to_string(logBuilder)))
}
