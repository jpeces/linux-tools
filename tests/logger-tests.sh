#!/bin/bash
import::include ../core/logger/logger.sh

function test() {
    logger::log 1 "debug test"

}
function test2() {
    test
}

# logger::setLogFile ./kk

logger::log 0 "None test"
logger::log 1 "Debug test"
logger::log 2 "Info test"
logger::log 3 "Warning test"
logger::log 4 "Error test"

logger::log 3 "test no newline..." -
logger::log 3 "continuation"

logger::banner "Test Banner"
