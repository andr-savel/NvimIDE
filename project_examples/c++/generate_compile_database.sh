#!/bin/bash

PROJECT_PATH="`dirname \"$0\"`"                    # relative path
PROJECT_PATH="`realpath $PROJECT_PATH`"            # absolute path

(
    cd $PROJECT_PATH
    rm `find ./ -name compile_commands.json`

    cmake -B ${PROJECT_PATH}/build/Debug -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    compdb -p "${PROJECT_PATH}/build/Debug" list > compile_commands.json
)

